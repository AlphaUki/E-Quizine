<?php

/**
 * Modèle de la base de données.
 *
 * @author     Nicolas LE BARS <nicolas.lebars1@etudiant.univ-brest.fr>
 */
class Db_model extends CI_Model {

	/**
	 * Construit une nouvelle instance.
	 */
	public function __construct() {
		$this->load->database();
		$this->load->library('session');
	}

	/**
	 * Vérifie si une session est active et si elle est valide.
	 *
	 * @return     bool  Validité de la session
	 */
	public function session_is_valid() {
		if (!$this->session->has_userdata('registration_date'))
			return false;

		$man_id = $this->session->userdata('id');
		$man_pseudo = $this->session->userdata('pseudo');
		$pfl_role = $this->session->userdata('role');
		$pfl_first_name = $this->session->userdata('first_name');
		$pfl_last_name = $this->session->userdata('last_name');
		$pfl_registration_date = $this->session->userdata('registration_date');

		$result = $this->db->query("
			SELECT pfl_active
			FROM T_MANAGER_man
			JOIN T_PROFILE_pfl USING(man_id)
			WHERE man_id = ".$man_id." && man_pseudo = '".$man_pseudo."' && pfl_role = '".$pfl_role."' && pfl_first_name = '".$pfl_first_name."' && pfl_last_name = '".$pfl_last_name."' && pfl_registration_date = '".$pfl_registration_date."';
		")->row();

		if ($result != null) {
			if ($result->pfl_active != 1) {
				$this->session->sess_destroy();
				return false;
			} else {
				return true;
			}
		} else {
			return false;
		}
	}

	/**
	 * Récupère les informations des utilisateurs(profils et comptes).
	 *
	 * @return     array  Les utilisateurs
	 */
	public function get_users()
	{
		$query = $this->db->query("
			SELECT T_MANAGER_man.man_id, T_MANAGER_man.man_pseudo,
				T_PROFILE_pfl.pfl_first_name, T_PROFILE_pfl.pfl_last_name, T_PROFILE_pfl.pfl_role,
				T_PROFILE_pfl.pfl_registration_date, T_PROFILE_pfl.pfl_active
			FROM T_MANAGER_man
			JOIN T_PROFILE_pfl USING(man_id);
		");
		return $query->result_array();
	}

	/**
	 * Récupère les information d'un utilisateur(profil et compte).
	 *
	 * @param      string  $man_pseudo  Le pseudo
	 * @param      string  $man_pw      Le mot de passe
	 *
	 * @return     array   L'utilisateur
	 */
	public function get_user($man_pseudo = null, $man_pw = null) {
		if ($man_pseudo == null || $man_pw == null)
			return null;

		$query = $this->db->query("
			SELECT T_MANAGER_man.*, T_PROFILE_pfl.*
			FROM T_MANAGER_man
			JOIN T_PROFILE_pfl USING(man_id)
			WHERE man_pseudo = '".$man_pseudo."' && man_pw = FN_HASH_PW('".$man_pw."');
		");
		return $query->row();
	}

	/**
	 * Met à jour les informations d'un utilisateur.
	 *
	 * @param      string  $man_id          L'identifiant
	 * @param      string  $man_pw          Le mot de passe
	 * @param      string  $new_first_name  Le nouveau prénom
	 * @param      string  $new_last_name   Le nouveau nom
	 * @param      string  $new_pw          Le nouveau mot de passe
	 *
	 * @return     bool    Le statut de la mise à jour
	 */
	public function update_user($man_id = -1, $man_pw = null, $new_last_name = null, $new_first_name = null, $new_pw = null) {
		if ($man_id == -1 || ($man_pw == null && $new_last_name == null && $new_first_name == null && $new_pw == null))
			return false;

		$query = false;

		if ($man_pw != null && $new_pw != null) {
			$query = $this->db->query("UPDATE T_MANAGER_man SET man_pw = FN_HASH_PW('".$new_pw."') WHERE man_id = ".$man_id." && man_pw = FN_HASH_PW('".$man_pw."');");

			if ($this->db->affected_rows() <= 0)
				return false;
		}

		$pfl_req = "";

		if ($new_last_name != null)
			$pfl_req .= "UPDATE T_PROFILE_pfl SET pfl_last_name = '".$new_last_name."'";

		if ($new_first_name != null) {
			if ($new_last_name == null) {
				$pfl_req .= "UPDATE T_PROFILE_pfl SET ";
			} else {
				$pfl_req .= ", ";
			}
			$pfl_req .= "pfl_first_name = '".$new_first_name."'";
		}

		if ($pfl_req != "")
			$query = $this->db->query($pfl_req." WHERE man_id = ".$man_id."; ");

		return $query;
	}

	/**
	 * Récupère les informations des matches(auteur, match, quiz, questions,
	 * réponses).
	 *
	 * @param      string   $match_code  Le code
	 * @param      integer  $match_id    L'identifiant
	 *
	 * @return     array    Le(s) match(es) associé(s).
	 */
	public function get_matches($match_code = null, $match_id = -1) {
		$req = "
			SELECT man_id, man_pseudo, man_pseudo_quiz, 
				match_id, match_code, match_title, 
				match_start_date, match_end_date, match_show_answers, 
				match_enabled, FN_MATCH_AVERAGE_SCORE(match_id) AS match_average_score,
				quiz_id, quiz_title, quiz_image, 
				quiz_enabled,
				qst_id, qst_content, qst_image, 
				qst_order, qst_enabled, 
				ans_id, ans_content, ans_image, 
				ans_valid
			FROM T_MATCH_match
			JOIN T_MANAGER_man USING(man_id)
            JOIN (
				SELECT quiz_id, quiz_title, quiz_image, 
				quiz_enabled, man_pseudo AS man_pseudo_quiz
				FROM T_QUIZ_quiz
                JOIN T_MANAGER_man USING(man_id)
			) AS tmp USING(quiz_id)
			JOIN T_QUESTION_qst USING(quiz_id)
			JOIN T_ANSWER_ans USING(qst_id)
		";

		if ($match_code != null)
			$req .= " WHERE match_code = '".$match_code."'";

		if ($match_id != -1)
		{
			if ($match_code != null)
				$req .= " && ";
			else
				$req .= " WHERE ";
			$req .= "match_id = ".$match_id;
		}

		$req .= " ORDER BY match_id DESC, qst_order, ans_id ASC;";

		$query = $this->db->query($req);
		return $query->result_array();
	}

	/**
	 * Créer un match.
	 *
	 * @param      string   $match_code          Le code
	 * @param      string   $match_title         Le titre
	 * @param      integer  $match_start_date    La date de début
	 * @param      integer  $match_end_date      La date de fin
	 * @param      integer  $match_show_answers  Les réponses sont visibles
	 * @param      integer  $match_enabled       Le match est activé
	 * @param      string   $quiz_id             L'identifiant du quiz associé
	 * @param      string   $man_id              L'identifiant de l'auteur
	 *
	 * @return     bool     Le statut de l'insertion
	 */
	public function create_match($match_code = null, $match_title = null, $match_start_date = null, $match_end_date = null, $match_show_answers = -1, $match_enabled = -1, $quiz_id = -1, $man_id = -1) {
		if ($match_code == null || $match_title == null || $match_show_answers == -1 || $match_enabled == -1 || $quiz_id == -1 || $man_id == -1)
			return false;

		$query = $this->db->query("
			INSERT INTO T_MATCH_match(match_code, match_title, match_start_date, match_end_date, match_show_answers, match_enabled, quiz_id, man_id) VALUES
				(
					'".$match_code."', 
					'".$match_title."', 
					".($match_start_date == null ? "NULL" : "'".date('Y-m-d', $match_start_date)."'").", 
					".($match_end_date == null ? "NULL" : "'".date('Y-m-d', $match_end_date)."'").", 
					".$match_show_answers.", 
					".$match_enabled.", 
					".$quiz_id.", 
					".$man_id."
				);

		");
		return $query;
	}

	/**
	 * Met à jour un match.
	 *
	 * @param      integer  $man_id              L'identifiant de l'auteur
	 * @param      integer  $match_id            L'identifiant
	 * @param      string   $match_code          Le code
	 * @param      string   $match_title         Le titre
	 * @param      integer  $match_start_date    La date de début
	 * @param      integer  $match_end_date      La date de fin
	 * @param      integer  $match_show_answers  Les réponses sont visibles
	 * @param      integer  $match_enabled       Le match est activé
	 *
	 * @return     bool     Le statut de la mise à jour
	 */
	public function update_match($match_id = -1,  $match_code = null, $match_title = null, $match_start_date = -1, $match_end_date = -1, $match_show_answers = null, $match_enabled = null) {
		if ($match_id == -1 || ($match_code == null && $match_title == null && $match_start_date == -1 && $match_end_date == -1 && $match_show_answers == -1 && $match_enabled == -1))
			return false;

		$columns = array();

		if ($match_code != null)
			array_push($columns, "match_code = '".$match_code."'");

		if ($match_title != null)
			array_push($columns, "match_title = '".$match_title."'");

		if ($match_start_date != -1)
			array_push($columns, "match_start_date = ".($match_start_date == null ? "NULL" : "'".date('Y-m-d', $match_start_date)."'"));

		if ($match_end_date != -1)
			array_push($columns, "match_end_date = ".($match_end_date == null ? "NULL" : "'".date('Y-m-d', $match_end_date)."'"));

		if ($match_show_answers != -1)
			array_push($columns, "match_show_answers = ".$match_show_answers);

		if ($match_enabled != -1)
			array_push($columns, "match_enabled = ".$match_enabled);

		$req = "UPDATE T_MATCH_match SET ";

		foreach ($columns as $col) {
			$req .= $col.", ";
		}

		$query = $this->db->query(substr($req, 0, -2)." WHERE match_id = ".$match_id.";");
		return $query;
	}

	/**
	 * Supprime un match.
	 *
	 * @param      string  $match_id  L'identifiant
	 *
	 * @return     bool    Le statut de la suppression
	 */
	public function delete_match($match_id = -1) {
		if ($match_id == -1)
			return false;

		$query = $this->db->query("
			DELETE FROM T_MATCH_match
			WHERE match_id = ".$match_id.";
		");
		return $query;
	}

	/**
	 * Récupère les informations d'un joueur.
	 *
	 * @param      string   $player_pseudo  Le pseudo
	 * @param      integer  $match_id       L'identifiant du match
	 *
	 * @return     array    Le joueur
	 */
	public function get_player($player_pseudo = null, $match_id = -1) {
		if ($player_pseudo == null || $match_id == -1)
			return null;

		$query = $this->db->query("
			SELECT player_pseudo, player_score, match_id
			FROM T_PLAYER_player
			WHERE player_pseudo = '".$player_pseudo."'".($match_id != -1 ? " && match_id = ".$match_id : "").";
		");
		return $query->row();
	}

	/**
	 * Ajoute un joueur.
	 *
	 * @param      string  $player_pseudo  Le pseudo
	 * @param      string  $match_id       L'identifiant du match
	 *
	 * @return     bool    Le statut de l'ajout
	 */
	public function add_player($player_pseudo = NULL, $player_score = -1, $match_id = -1) {
		if ($player_pseudo == NULL || $player_score == -1 || $match_id == -1)
			return false;

		$query = $this->db->query("
			INSERT INTO T_PLAYER_player (player_pseudo, player_score, match_id) VALUES
				('".$player_pseudo."', ".$player_score.", ".$match_id.");
		");
		return $query;
	}

	/**
	 * Récupère les quiz actifs et les matches associés si il y en à.
	 *
	 * @return     array  Les quiz et les matches.
	 */
	public function get_quiz_and_matches() {
		$query = $this->db->query("
			SELECT quiz_id, quiz_title, quiz_enabled, 
				quiz.man_id AS man_id_quiz, 
			    T_MANAGER_man.man_pseudo AS man_pseudo_quiz,
				match_id, match_title, match_code, 
			    match_start_date, match_end_date, match_show_answers, 
			    match_enabled, tmp.man_id, tmp.man_pseudo
			FROM T_QUIZ_quiz AS quiz
			JOIN T_MANAGER_man USING(man_id)
			LEFT OUTER JOIN (
				SELECT match_id, match_title, match_code, 
                	match_start_date, match_end_date, match_show_answers, 
                	match_enabled, quiz_id, man_id, man_pseudo
			    FROM T_MATCH_match
			    JOIN T_MANAGER_man USING(man_id)
			) AS tmp USING(quiz_id)
			WHERE quiz_enabled = 1
			ORDER BY match_id;
		");
		return $query->result_array();
	}

	/**
	 * Récupère les informations d'un quiz(quiz + questions + réponses +
	 * auteur).
	 *
	 * @param      string  $quiz_id   L'identifiant
	 * @param      bool    $complete  Le quiz doit être complet (Une question
	 *                                active minimum)
	 *
	 * @return     array   Les informations du quiz
	 */
	public function get_quiz($quiz_id = -1, $complete = false) {
		if ($quiz_id == -1)
			return array();

		$req = "
			SELECT qst_id, quiz_title, quiz_enabled, 
			    man_id, man_pseudo, qst_content, qst_order, 
			    qst_enabled, ans_id, ans_content, 
			    ans_image, ans_valid
			FROM T_QUIZ_quiz
            JOIN T_MANAGER_man USING(man_id)
			JOIN T_QUESTION_qst USING(quiz_id)
			JOIN T_ANSWER_ans USING(qst_id)
			WHERE quiz_id = ".$quiz_id."
		";

		if ($complete)
			$req .= " && 0 < (
					SELECT COUNT(qst_enabled)
				    FROM T_QUESTION_qst
				    JOIN T_ANSWER_ans USING(qst_id)
				    WHERE quiz_id = Q1.quiz_id
				)
			";

		$query = $this->db->query($req.";");
		return $query->result_array();
	}

	/**
	 * Récupère une actualité.
	 *
	 * @param      string  $id     L'identifiant
	 *
	 * @return     array   L'actualité
	 */
	public function get_news($id)
	{
		$query = $this->db->query("SELECT new_id, new_title, new_content FROM T_NEWS_new WHERE new_id = ".$id.";");
		return $query->row();
	}

	/**
	 * Récupère toutes les actualités.
	 *
	 * @return     array  Les actualités
	 */
	public function get_all_news()
	{
		$query = $this->db->query("SELECT new_id, new_title, new_content, new_date, man_pseudo FROM T_NEWS_new JOIN T_MANAGER_man USING(man_id) ORDER BY new_date DESC LIMIT 5;");
		return $query->result_array();
	}
}
?>