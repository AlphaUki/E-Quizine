<div class="row">
	<div class="col-12 grid-margin">
		<div class="card">
			<div class="card-body">
				<div class="container-fluid p-0 m-0">
					<h4 class="card-title d-inline"><?php echo $match[0]['match_title']; ?></h4>
					<button type="button" class="d-inline float-right btn btn-success" id="showGAns">Afficher les bonnes réponses</button>
				</div>
				<p>Code : <?php echo $match[0]['match_code']; ?>
				<p>
					Commencé le <?php
						echo $match[0]['match_start_date'];

						if (isset($match[0]['match_end_date']))
							echo " et fini le ".$match[0]['match_end_date'];
					?>
				</p>
				<p>Activé : <?php echo $match[0]['match_enabled'] ? "Vrai" : "Faux"; ?></p>
				<p>Afficher les réponses : <?php echo $match[0]['match_show_answers'] ? "Vrai" : "Faux"; ?></p>
				<p>Auteur : <?php echo $match[0]['man_pseudo']; ?></p>
				<p>Score moyen : <?php echo number_format($match[0]['match_average_score'], 2); ?>%</p>
				<?php
					$qst_id = -1;

					foreach ($match as $question) {
						$qst_name = "q".$question['qst_id'];

						if ($qst_id != $question['qst_id'])
						{
							if ($qst_id != -1)
								echo "
												</ul>
											</div>
										</div>
									</div>
								";

							echo "
								<div class=\"card border-info mb-4\">
									<div class=\"card-header bg-info\" role=\"button\" data-toggle=\"collapse\" data-target=\"#".$qst_name."\">
										<span class=\"card-title\">Question ".($question['qst_order'] + 1)."</span>
									</div>
									<div class=\"collapse show\" id=\"".$qst_name."\">
										<div class=\"card-body\">
											<p>".$question['qst_content']."</p>
											<ul>
							";

							$qst_id = $question['qst_id'];
						}

						if ($question['ans_valid'] == 1) {
							echo "<li class=\"gans\">";
						} else {
							echo "<li>";
						}

						echo $question['ans_content']."</li>";
					}

					if ($qst_id != -1)
						echo "
									</div>
								</div>
							</div>
						";
				?>
				<script>
					$(document).ready(() => {
						var gans_displayed = false;

						$("#showGAns").click(event => {
							gans_displayed = !gans_displayed;

							if (gans_displayed == true) {
								$(".gans").addClass("text-success");
								$(event.target).html("Cacher les bonnes réponses");
								$(event.target).removeClass("btn-success").addClass("btn-danger");
							} else {
								$(".gans").removeClass("text-success");
								$(event.target).html("Afficher les bonnes réponses");
								$(event.target).removeClass("btn-danger").addClass("btn-success");
							}
						});
					});
				</script>
			</div>
		</div>
	</div>
</div>