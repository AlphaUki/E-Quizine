<?php
defined('BASEPATH') OR exit('No direct script access allowed');

/**
 * Controlleur des Matches.
 *
 * @author     Nicolas LE BARS <nicolas.lebars1@etudiant.univ-brest.fr>
 */
class Match extends CI_Controller {

	/**
	 * Construit une nouvelle instance.
	 */
	public function __construct() {
		parent::__construct();
		$this->load->model('db_model');
		$this->load->helper('url');
		$this->load->library('form_validation');
		$this->load->library('session');
	}

	/**
	 * Vérifie si les informations d'un match sont valides.
	 *
	 * @param      array  $match  Le match
	 *
	 * @return     bool   La validité du match
	 */
	protected function match_is_valid($match) {
		$curr_time = strtotime(date("Y-m-d"));
		$mDateStart = strtotime($match['match_start_date']);
		$mDateEnd = strtotime($match['match_end_date']);

		return $match['match_enabled'] == 1
			&& $match['quiz_enabled'] == true
			&& $mDateStart != null && $mDateStart <= $curr_time
			&& ($mDateEnd == null || ($mDateStart < $mDateEnd));
	}

	/**
	 * Permet de vérifier si un code est associé à au moins un match.
	 * Seul les requêtes AJAX sont autorisées.
	 */
	public function check_code() {
		if(!$this->input->is_ajax_request()) {
			echo "No direct script is allowed";
			exit();
		}

		$this->form_validation->set_rules('mCode', 'MatchCode', 'trim|required|alpha_numeric|exact_length[8]|strtoupper');

		if (!$this->form_validation->run()) {
			$result['status'] = "error";
			$result['message'] = validation_errors();
		} else {
			$match_code = $this->input->post('mCode');

			$matches = array();
			$match_id = -1;

			foreach ($this->db_model->get_matches($match_code) as $match) {
				if ($match_id != $match['match_id'] && $this->match_is_valid($match)) {
					array_push($matches, [$match['match_id'], $match['match_title'], $match['man_pseudo']]);
					$match_id = $match['match_id'];
				}
			}

			if (empty($matches)) {
				$result['status'] = "abort";
				$result['message'] = "There is no match associated with the code \"".$match_code."\"";
			} else {
				$result['status'] = "success";
				$result['message'] = "the data related to the matches with code \"".$match_code."\", have been retrieved";
				$result['data'] = $matches;
			}
		}

		$this->output->set_content_type('application/json');
		$this->output->set_output(json_encode($result));
		echo $this->output->get_output();
		exit();
	}

	/**
	 * Permet de vérifier si un pseudo est disponible pour un match.
	 * Seul les requêtes AJAX sont autorisées.
	 */
	public function check_pseudo() {
		if(!$this->input->is_ajax_request()) {
			echo "No direct script is allowed";
			exit();
		}

		$this->form_validation->set_rules('pPseudo', 'PlayerPseudo', 'trim|required|max_length[20]');
		$this->form_validation->set_rules('mId', 'MatchId', 'trim|required|is_natural_no_zero');

		if (!$this->form_validation->run()) {
			$result['status'] = "error";
			$result['message'] = validation_errors();
		} else {
			$player_pseudo = $this->input->post('pPseudo');
			$match_id = $this->input->post('mId');
			$player_is_valid = $this->db_model->get_player($player_pseudo, $match_id) == null;

			if ($player_is_valid == false) {
				$result['status'] = "abort";
				$result['message'] = "The pseudo \"".$player_pseudo."\" is already used for the match of id ".$match_id;
			} else {
				$this->session->set_flashdata('player_pseudo', $player_pseudo);
				$this->session->set_flashdata('player_match', $match_id);

				$result['status'] = "success";
				$result['message'] = "The player \"".$player_pseudo."\" has been created and linked to match of id ".$match_id;
			}
		}

		$this->output->set_content_type('application/json');
		$this->output->set_output(json_encode($result));
		echo $this->output->get_output();
		exit();
	}

	/**
	 * Affiche les informations d'un match du points de vue d'un joueur.
	 *
	 * @param      string   $match_code  Le code
	 * @param      integer  $match_id    L'identifiant
	 */
	public function show($match_code = null, $match_id = -1) {
		if ($match_code == null && $match_id == -1) {
			header("Location:".base_url());
		} else {
			$quiz_and_matches = $this->db_model->get_matches($match_code, $match_id);

			if ($quiz_and_matches == null || !$this->match_is_valid($quiz_and_matches[0])) {
				echo "
					<script>
						alert(\"Ce match n'existe pas!\");
						window.location.href = \"".base_url()."\"
					</script>
				";
				exit();
			}

			$data['quiz_and_match'] = array();
			$match_id = $quiz_and_matches[0]['match_id'];

			foreach ($quiz_and_matches as $match) {
				if ($match['match_id'] == $match_id)
					array_push($data['quiz_and_match'], $match);
			}

			$player_pseudo = $this->session->keep_flashdata('player_pseudo');
			$match_id = $this->session->keep_flashdata('player_match');

			$this->load->view('templates/header');
			$this->load->view('match_show', $data);
			$this->load->view('templates/footer');
		}
	}

	/**
	 * Affiche la liste des matches.
	 * Un utilisateur doit être connecté.
	 */
	public function list() {
		if (!$this->db_model->session_is_valid()) {
			header("Location:".base_url());
		} else {
			$data['quiz_and_matches'] = $this->db_model->get_quiz_and_matches();

			$this->load->view('templates/header_manager');
			$this->load->view('match_list', $data);
			$this->load->view('templates/footer');
		}
	}

	/**
	 * Affiche les informations d'un match du points de vue d'un utilisateur.
	 * Un utilisateur doit être connecté.
	 *
	 * @param      string   $match_code  Le code
	 * @param      integer  $match_id    L'identifiant
	 */
	public function info($match_code = null, $match_id = -1) {
		if ($match_code == null || $match_id == -1 || !$this->db_model->session_is_valid()) {
			header("Location:".base_url());
		} else {
			$matches = $this->db_model->get_matches($match_code, $match_id);

			if ($matches == null) {
				echo "
					<script>
						alert(\"Ce match n'existe pas!\");
						window.location.href = \"".base_url()."\"
					</script>
				";
				exit();
			}

			$data['match'] = array();
			$match_id = $matches[0]['match_id'];

			foreach ($matches as $match) {
				if ($match['match_id'] == $match_id)
					array_push($data['match'], $match);
			}

			$this->load->view('templates/header_manager');
			$this->load->view('match_info', $data);
			$this->load->view('templates/footer');
		}
	}

	/**
	 * Utilisé pour la création d'un match.
	 * Seul les requêtes AJAX sont autorisées.
	 * Un utilisateur doit être connecté.
	 */
	public function create() {
		if(!$this->input->is_ajax_request()) {
			echo "No direct script is allowed";
			exit();
		}

		if (!$this->db_model->session_is_valid()) {
			$result['status'] = "error";
			$result['message'] = "There is no active session";
		} else {
			$this->form_validation->set_rules('mTitle', 'MatchTitle', 'trim|required|min_length[3]|max_length[200]');
			$this->form_validation->set_rules('mShowAnswers', 'MatchAnswersAreVisible', 'trim|required|regex_match[/^[01]$/]');
			$this->form_validation->set_rules('mEnabled', 'MatchIsEnabled', 'trim|required|regex_match[/^[01]$/]');
			$this->form_validation->set_rules('mQuiz', 'MatchQuiz', 'trim|required|is_natural_no_zero');

			function is_date($strdate) {
				$d = DateTime::createFromFormat("Y-m-d", $strdate);
			    return $d && $d->format("Y-m-d") === $strdate;
			}

			$this->form_validation->set_rules('mDateStart', 'MatchStartDate', 'trim|is_date');
			$this->form_validation->set_rules('mDateEnd', 'MatchEndDate', 'trim|is_date');

			$mDateStart = strtotime($this->input->post('mDateStart'));
			$mDateEnd = strtotime($this->input->post('mDateEnd'));

			if ($mDateStart == null && $mDateEnd != null) {
				$result['status'] = "abort";
				$result['message'] = "The end date can only be defined with a start date";
			} else {
				if ($mDateStart != null && $mDateStart < strtotime(date('Y-m-d'))) {
					$result['status'] = "abort";
					$result['message'] = "The start date is invalid";
				} else if ($mDateEnd != null && $mDateEnd < strtotime(date('Y-m-d')."+1 days")) {
					$result['status'] = "abort";
					$result['message'] = "The end date is invalid";
				} else if ($mDateStart != null && $mDateEnd != null && $mDateStart >= $mDateEnd) {
					$result['status'] = "abort";
					$result['message'] = "The start date cannot be after the end date";
				} else if (!$this->form_validation->run()) {
					$result['status'] = "error";
					$result['message'] = validation_errors();
				} else {
					$mTitle = $this->input->post('mTitle');
					$mShowAnswers = $this->input->post('mShowAnswers');
					$mEnabled = $this->input->post('mEnabled');
					$mQuiz = $this->input->post('mQuiz');
					$quiz = $this->db_model->get_quiz($mQuiz);

					if ($quiz == null) {
						$result['status'] = "abort";
						$result['message'] = "The quiz is incomplete";
					} else {
						function getRandomCode() {
							$randomCode = "";
							$chars = "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ";

							for ($i = 0; $i < 8; $i++) {
								$randomCode .= $chars[rand(0, strlen($chars) - 1)];
							}

							return $randomCode;
						}

						$mCode = getRandomCode();

						$this->db_model->create_match($mCode, $mTitle, $mDateStart, $mDateEnd, $mShowAnswers, $mEnabled, $mQuiz, $this->session->userdata('id'));

						if ($this->db->affected_rows() <= 0) {
							$result['status'] = "error";
							$result['message'] = "Something went wrong during the match creation";
						} else {
							$result['status'] = "success";
							$result['message'] = "The match has been created";
							$result['data'] = array(
							 	"qTitle" => $quiz[0]['quiz_title'], 
								"qAutor" => $quiz[0]['man_pseudo'], 
								"mCode" => $mCode, 
								"mId" => $this->db->insert_id(),
								"mAutor" => $this->session->userdata('pseudo')
							);
						}
					}
				}
			}

			
		}

		$this->output->set_content_type('application/json');
		$this->output->set_output(json_encode($result));
		echo $this->output->get_output();
		exit();
	}

	/**
	 * Utilisé pour la suppression d'un match.
	 * Seul les requêtes AJAX sont autorisées.
	 * Un utilisateur doit être connecté.
	 */
	public function delete() {
		if(!$this->input->is_ajax_request()) {
			echo "No direct script is allowed";
			exit();
		}

		if (!$this->db_model->session_is_valid()) {
			$result['status'] = "error";
			$result['message'] = "There is no active session";
		} else {
			$this->form_validation->set_rules('mCode', 'MatchCode', 'trim|required|alpha_numeric|exact_length[8]|strtoupper');
			$this->form_validation->set_rules('mId', 'MatchId', 'trim|required|is_natural_no_zero');

			if (!$this->form_validation->run()) {
				$result['status'] = "error";
				$result['message'] = validation_errors();
			} else {
				$match_code = $this->input->post('mCode');
				$match_id = $this->input->post('mId');
				$match = $this->db_model->get_matches($match_code, $match_id);

				if ($match == null) {
					$result['abord'] = "error";
					$result['message'] = "This match does not exist";
				} else if ($this->session->userdata('role') != "A" && $match[0]['man_id'] != $this->session->userdata('id')) {
					$result['status'] = "error";
					$result['message'] = "You are not the author of this match";
				} else {
					$this->db_model->delete_match($match_id);

					if ($this->db->affected_rows() <= 0) {
						$result['status'] = "error";
						$result['message'] = "Something went wrong during the match deletion";
					} else {
						$result['status'] = "success";
						$result['message'] = "The match has been deleted";
					}
				}
			}
		}

		$this->output->set_content_type('application/json');
		$this->output->set_output(json_encode($result));
		echo $this->output->get_output();
		exit();
	}

	/**
	 * Utilisé pour le changement de statut d'un match.
	 * Seul les requêtes AJAX sont autorisées.
	 * Un utilisateur doit être connecté.
	 */
	public function change_status() {
		if(!$this->input->is_ajax_request()) {
			echo "No direct script is allowed";
			exit();
		}

		if (!$this->db_model->session_is_valid()) {
			$result['status'] = "error";
			$result['message'] = "There is no active session";
		} else {
			$this->form_validation->set_rules('mCode', 'MatchCode', 'trim|required|alpha_numeric|exact_length[8]|strtoupper');
			$this->form_validation->set_rules('mId', 'MatchId', 'trim|required|is_natural_no_zero');

			if (!$this->form_validation->run()) {
				$result['status'] = "error";
				$result['message'] = validation_errors();
			} else {
				$match_code = $this->input->post('mCode');
				$match_id = $this->input->post('mId');
				$match = $this->db_model->get_matches($match_code, $match_id);

				if ($match == null) {
					$result['abord'] = "error";
					$result['message'] = "This match does not exist";
				} else if ($this->session->userdata('role') != "A" && $match[0]['man_id'] != $this->session->userdata('id')) {
					$result['status'] = "error";
					$result['message'] = "You are not the author of this match";
				} else {
					$this->db_model->update_match($match_id, null, null, -1, -1, -1, ($match[0]['match_enabled'] == 1 ? 0 : 1));

					if ($this->db->affected_rows() <= 0) {
						$result['status'] = "error";
						$result['message'] = "Something went wrong when changing the match status";
					} else {
						$result['status'] = "success";
						$result['message'] = "The match status has been changed";
					}
				}
			}
		}

		$this->output->set_content_type('application/json');
		$this->output->set_output(json_encode($result));
		echo $this->output->get_output();
		exit();
	}

	/**
	 * Utilisé pour réinitialiser un match.
	 * Seul les requêtes AJAX sont autorisées.
	 * Un utilisateur doit être connecté.
	 */
	public function reset() {
		if(!$this->input->is_ajax_request()) {
			echo "No direct script is allowed";
			exit();
		}

		if (!$this->db_model->session_is_valid()) {
			$result['status'] = "error";
			$result['message'] = "There is no active session";
		} else {
			$this->form_validation->set_rules('mCode', 'MatchCode', 'trim|required|alpha_numeric|exact_length[8]|strtoupper');
			$this->form_validation->set_rules('mId', 'MatchId', 'trim|required|is_natural_no_zero');

			if (!$this->form_validation->run()) {
				$result['status'] = "error";
				$result['message'] = validation_errors();
			} else {
				$match_code = $this->input->post('mCode');
				$match_id = $this->input->post('mId');
				$match = $this->db_model->get_matches($match_code, $match_id);

				if ($match == null) {
					$result['abord'] = "error";
					$result['message'] = "This match does not exist";
				} else if ($this->session->userdata('role') != "A" && $match[0]['man_id'] != $this->session->userdata('id')) {
					$result['status'] = "error";
					$result['message'] = "You are not the author of this match";
				} else {
					$this->db_model->update_match($match_id, null, null, null, null, -1, -1);

					if ($this->db->affected_rows() <= 0) {
						$result['status'] = "error";
						$result['message'] = "Something went wrong during the match reset";
					} else {
						$result['status'] = "success";
						$result['message'] = "The match has been reset and the associated players have been deleted";
					}
				}
			}
		}

		$this->output->set_content_type('application/json');
		$this->output->set_output(json_encode($result));
		echo $this->output->get_output();
		exit();
	}

	/**
	 * Utilisé pour vérifier et enregistrer les réponses d'un joueur.
	 * Seul les requêtes AJAX sont autorisées.
	 * Les informations d'un joueur doivent être accessibles.
	 */
	public function result() {
		if(!$this->input->is_ajax_request()) {
			echo "No direct script is allowed";
			exit();
		}

		$player_pseudo = $this->session->flashdata('player_pseudo');
		$match_id = $this->session->flashdata('player_match');

		if ($player_pseudo == null || $match_id == null) {
			$result['status'] = "error";
			$result['message'] = "There is no active player ".$player_pseudo;
		} else {
			$answers = $this->input->post('answers');

			if ($answers == null || !is_array($answers)) {
				$result['status'] = "error";
				$result['message'] = "Incomplete or invalid data";
			} else {
				$match = $this->db_model->get_matches(null, $match_id);

				$nb_questions = 0;
				$correct_answers = 0;

				$qst_id = -1;
				foreach($match as $info) {
					if ($qst_id != $info['qst_id']) {
						$nb_questions++;
						$qst_id = $info['qst_id'];
					}

					if ($info['ans_valid'] == 1 && in_array($info['ans_id'], $answers)) {
						$correct_answers++;
					}
				}

				if (count($answers) != $nb_questions) {
					$result['status'] = "abord";
					$result['message'] = "The number of answers does not match the number of questions";
				} else {
					$score = ($correct_answers / $nb_questions) * 100;
					$this->db_model->add_player($player_pseudo, $score, $match_id);

					if ($this->db->affected_rows() <= 0) {
						$result['status'] = "error";
						$result['message'] = "Something went wrong when adding the player information";
					} else {
						$result['status'] = "success";
						$result['message'] = "The player's score has been saved";
						$result['score'] = $score;
					}
				}
			}
		}

		$this->output->set_content_type('application/json');
		$this->output->set_output(json_encode($result));
		echo $this->output->get_output();
		exit();
	}
}
?>