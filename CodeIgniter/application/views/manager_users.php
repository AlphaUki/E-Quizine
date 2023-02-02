<div class="row">
	<div class="col-12 grid-margin">
		<div class="card">
			<div class="card-body">
				<h4 class="card-title">Liste des utilisateurs</h4>
				<?php
					if (!isset($users)) {
						echo "<p class=\"text-center font-weight-bold\">Il n'y a pas d'utilisateur pour le moment</p>";
					} else {
						echo "<p>Nombre de comptes : ".count($users)."</p>";
						echo "
							<div class=\"table-responsive\">
								<table class=\"table\">
									<thead>
										<tr>
											<th>Pseudo</th>
											<th>Prénom</th>
											<th>Nom</th>
											<th>Rôle</th>
											<th>Date d'inscription</th>
											<th>Activé / Désactiver</th>
										</tr>
									</thead>
									<tbody>
						";
									 
						foreach ($users as $user) {
							echo "
								<tr>
									<td>".$user['man_pseudo']."</td>
									<td>".$user['pfl_first_name']."</td>
									<td>".$user['pfl_last_name']."</td>
									<td>".$user['pfl_role']."</td>
									<td>".$user['pfl_registration_date']."</td>
									<td>".$user['pfl_active']."</td>
								</tr>
							";
						}

						echo "
									</tbody>
								</table>
							</div>
						";
					}
				?>
			</div>
		</div>
	</div>
</div>