<div class="row">
	<div class="col-12 grid-margin">
		<div class="card">
			<div class="card-body">
				<h4 class="card-title">Liste des actualités</h4>
				<?php
					if (!isset($news)) {
						echo "<p class=\"text-center font-weight-bold\">Il n'y a pas d'actualité pour le moment</p>";
					} else {
						echo "
							<div class=\"table-responsive\">
								<table class=\"table\">
									<thead>
										<tr>
											<th>Titre</th>
											<th>Contenu</th>
											<th>Date</th>
											<th>Auteur</th>
										</tr>
									</thead>
									<tbody>
						";
									 
						foreach ($news as $s_news) {
							echo "
								<tr>
									<td class=\"text-wrap\">".$s_news["new_title"]."</td>
									<td class=\"text-wrap\">".$s_news["new_content"]."</td>
									<td>".$s_news["new_date"]."</td>
									<td>".$s_news["man_pseudo"]."</td>
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