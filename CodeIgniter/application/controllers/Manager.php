<?php
defined('BASEPATH') OR exit('No direct script access allowed');

/**
 * Controlleur des utilisateurs.
 *
 * @author     Nicolas LE BARS <nicolas.lebars1@etudiant.univ-brest.fr>
 */
class Manager extends CI_Controller {

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
	 * Si il ne s'agit pas d'une requête AJAX : Affiche la page de connexion.
	 * Sinon : Essaie de connecter l'utilisateur.
	 */
	public function login() {
		if (!$this->input->is_ajax_request()) {
			if ($this->db_model->session_is_valid()) {
				header("Location:".base_url());
			} else {
				$this->load->view('login');
			}
		} else {
			if ($this->db_model->session_is_valid()) {
				$result['status'] = "error";
				$result['message'] = "A session is already active";
			} else {
				$this->form_validation->set_rules('manPseudo', 'ManagerPseudo', 'trim|required|max_length[20]|alpha_dash');
				// regex_match[/^(?=.*\d)(?=.*[a-z])(?=.*[A-Z])(?=.*[a-zA-Z])+$/]
				$this->form_validation->set_rules('manPw', 'ManagerPassword', 'trim|required');

				if (!$this->form_validation->run()) {
					$result['status'] = "error";
					$result['message'] = validation_errors();
				} else {
					$man_pseudo = $this->input->post('manPseudo');
					$man_pw = $this->input->post('manPw');
					$man = $this->db_model->get_user($man_pseudo, $man_pw);

					if ($man == null || $man->pfl_active == false) {
						$result['status'] = "abort";
						$result['message'] = "The informations are incorrect or the user does not exist";
					} else {
						$this->session->set_userdata(array(
							'role' => $man->pfl_role,
							'pseudo' => $man_pseudo,
							'id' => $man->man_id,
							'first_name' => $man->pfl_first_name,
							'last_name' => $man->pfl_last_name,
							'registration_date' => $man->pfl_registration_date
						));

						$result['status'] = "success";
						$result['message'] = "Session created";
					}
				}
			}

			$this->output->set_content_type('application/json');
			$this->output->set_output(json_encode($result));
			echo $this->output->get_output();
			exit();
		}
	}

	/**
	 * Détruit la session existante.
	 */
	public function logout() {
		if(!$this->input->is_ajax_request()) {
			echo "No direct script is allowed";
			exit();
		}

		if (!$this->db_model->session_is_valid()) {
			$result['status'] = "error";
			$result['message'] = "There is no active session";
		} else {
			$this->session->sess_destroy();

			$result['status'] = "success";
			$result['message'] = "Session destroyed";
		}

		$this->output->set_content_type('application/json');
		$this->output->set_output(json_encode($result));
		echo $this->output->get_output();
		exit();
	}

	/**
	 * Affiche le pseudo, nom et prénom d'un utilisateur.
	 */
	public function details() {
		if (!$this->db_model->session_is_valid()) {
			header("Location:".base_url());
		} else {
			$this->load->view('account_details');
		}
	}

	/**
	 * Si il ne s'agit pas d'une requête AJAX : Affiche la page des paramètres
	 * de l'utilisateur.
	 * Sinon : Essaie de mettre à jour les informations de l'utilisateur.
	 */
	public function update() {
		if (!$this->input->is_ajax_request()) {
			if (!$this->db_model->session_is_valid()) {
				header("Location:".base_url());
			} else {
				$this->load->view('account_settings');
			}
		} else {
			if (!$this->db_model->session_is_valid()) {
				$result['status'] = "error";
				$result['message'] = "There is no active session";
			} else {
				$this->form_validation->set_rules('pflLastNameNew', 'ProfileLastName', 'trim|max_length[80]');
				$this->form_validation->set_rules('pflFirtNameNew', 'ProfileFirstName', 'trim|max_length[80]');

				$this->form_validation->set_rules('manPw', 'ManagerPassword', 'trim');
				$this->form_validation->set_rules('manPwNew', 'NewManagerPassword', 'trim');
				$this->form_validation->set_rules('manPwConfirm', 'ConfirmNewManagerPassword', 'trim');

				if (!$this->form_validation->run()) {
					$result['status'] = "error";
					$result['message'] = validation_errors();
				} else {
					$new_last_name = $this->input->post('pflLastNameNew');
					$new_first_name = $this->input->post('pflFirtNameNew');

					$man_pw = $this->input->post('manPw');
					$new_pw = $this->input->post('manPwNew');
					$confirm_pw = $this->input->post('manPwConfirm');

					if (($man_pw == null && $new_pw != null) || ($man_pw != null && $new_pw == null) || ($new_pw != null && $confirm_pw == null) || ($new_pw != null && $new_pw != $confirm_pw)) {
						$result['status'] = "abort";
						$result['message'] = "Missing password or the new password and the confirmation password do not match";
					} else {
						$this->db_model->update_user($this->session->userdata('id'), $man_pw, $new_last_name, $new_first_name, $new_pw);

						if ($this->db->affected_rows() <= 0) {
							$result['status'] = "error";
							$result['message'] = "Incorrect or incomplete informations";
						} else {
							if ($new_last_name != null) {
								$this->session->unset_userdata('last_name');
								$this->session->set_userdata('last_name', $new_last_name);
							}

							if ($new_first_name != null) {
								$this->session->unset_userdata('first_name');
								$this->session->set_userdata('first_name', $new_first_name);
							}

							$result['status'] = "success";
							$result['message'] = "Manager updated";
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

	/**
	 * Affiche les utilisateurs(profil et compte).
	 * Un administrateur doit être connecté.
	 */
	public function users() {
		if (!$this->db_model->session_is_valid() || $this->session->userdata('role') != "A") {
			header("Location:".base_url());
		} else {
			$data['users'] = $this->db_model->get_users();

			$this->load->view('templates/header_manager');
			$this->load->view('manager_users', $data);
			$this->load->view('templates/footer');
		}
	}
}
?>