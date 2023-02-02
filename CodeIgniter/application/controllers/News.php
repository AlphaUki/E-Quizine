<?php
defined('BASEPATH') OR exit('No direct script access allowed');

/**
 * Controlleur des actualités.
 *
 * @author     Nicolas LE BARS <nicolas.lebars1@etudiant.univ-brest.fr>
 */
class News extends CI_Controller {

	/**
	 * Construit une nouvelle instance.
	 */
	public function __construct()
	{
		parent::__construct();
		$this->load->model('db_model');
		$this->load->helper('url');
	}

	/**
	 * Affiche une actualité.
	 *
	 * @param      integer  $id     L'identifiant
	 */
	public function show($id = FALSE)
	{
		if ($id == FALSE)
		{
			$url = base_url();
			header("Location:$url");
		} else {
			$data['title'] = 'Actualité :';
			$data['news'] = $this->db_model->get_news($id);

			$this->load->view('templates/header');
			$this->load->view('news_show', $data);
			$this->load->view('templates/footer');
		}
	}

	/**
	 * Affiche toutes les actualités.
	 */
	public function list()
	{
		$data['title'] = 'Liste des actualités :';
		$data['news'] = $this->db_model->get_all_news();

		$this->load->view('templates/header');
		$this->load->view('news_list', $data);
		$this->load->view('templates/footer');
	}
}
?>