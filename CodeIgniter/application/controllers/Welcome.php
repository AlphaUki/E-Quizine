<?php
defined('BASEPATH') OR exit('No direct script access allowed');

/**
 * Controlleur de la page d'acceuil.
 *
 * @author     Nicolas LE BARS <nicolas.lebars1@etudiant.univ-brest.fr>
 */
class Welcome extends CI_Controller {

	/**
	 * Construit une nouvelle instance.
	 */
	public function __construct() {
		parent::__construct();
		$this->load->model('db_model');
		$this->load->helper('url');
		$this->load->library('session');
	}

	/**
	 * Affiche la page d'acceuil.
	 */
	public function show() {
		$data['news'] = $this->db_model->get_all_news();
		
		if (!$this->db_model->session_is_valid()) {
			$this->load->view('templates/header');
			$this->load->view('menu_guest');
			$this->load->view('news_list', $data);
			$this->load->view('templates/footer');
		} else {
			$this->load->view('templates/header_manager');
			$this->load->view('news_list', $data);
			$this->load->view('templates/footer');
		}
	}
}
?>