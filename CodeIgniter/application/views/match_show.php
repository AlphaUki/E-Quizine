<div class="row">
	<div class="col-12 grid-margin">
		<div class="card">
			<div class="card-body">
				<h4 class="card-title"><?php echo $quiz_and_match[0]['match_title']; ?></h4>
				<p>
					Commencé le 
					<?php
						echo $quiz_and_match[0]['match_start_date'];

						if ($quiz_and_match[0]['match_end_date'] != null)
							echo " et fini le ".$quiz_and_match[0]['match_end_date'];
					?>
				</p>
				<p>Créer par <?php echo $quiz_and_match[0]['man_pseudo']; ?></p>
				<?php
					$nb_questions = 0;
					$qst_id = -1;

					foreach ($quiz_and_match as $quiz) {
						if ($qst_id != $quiz['qst_id']) {
							if ($qst_id != -1)
								echo "
											</div>
										</div>
									</div>
								";

							echo "
								<div class=\"card border-info mb-4\">
									<div class=\"card-header bg-info\" role=\"button\" data-toggle=\"collapse\" data-target=\"#qst".$quiz['qst_id']."\">
										<span class=\"card-title\">Question ".($quiz['qst_order'] + 1)."</span>
									</div>
									<div class=\"collapse show\" id=\"qst".$quiz['qst_id']."\">
										<div class=\"card-body\">
											<p>".$quiz['qst_content']."</p>
							";

							$qst_id = $quiz['qst_id'];
							$nb_questions++;
						}

						echo "
							<div class=\"form-check form-check-info\">
								<label class=\"form-check-label text-light\" for=\"a".$quiz['ans_id']."\">
									<input type=\"radio\" class=\"form-check-input\" id=\"a".$quiz['ans_id']."\" name=\"a".$quiz['qst_id']."\"><i class=\"input-helper\"></i> ".$quiz['ans_content']."
								</label>
							</div>
						";
					}

					echo "
								</div>
							</div>
						</div>
					";
				?>
				<div class="d-grid d-flex justify-content-end">
					<button type="button" class="btn btn-primary btn-lg" id="qstSubmit" disabled>Valider</button>
				</div>
				<script>
					$(document).ready(() => {
						var answers = [];

						$("input[type='radio']").click(event => {
							$("input[name='" + event.target.name + "']").not(event.target).trigger("deselect");
							var ans = parseInt(event.target.id.substring(1));
							answers.push(ans);
							$("#qstSubmit").prop("disabled", answers.length != <?php echo $nb_questions; ?>);
						});

						$("input[type='radio']").on("deselect", event => {
							var ans = parseInt(event.target.id.substring(1));
						    answers = answers.filter(item => item != ans);
						})

						$("#qstSubmit").click(event => {
							$.ajax({
								type: "POST",
								url: "<?php echo base_url('index.php/match/result'); ?>",
								data: { answers: answers },
								dataType: "json",
								success: res => {
									switch (res.status) {
										case "success":
											alert(res.score.toFixed(2) + "% de vos réponses sont bonnes !");
											window.location = "<?php echo base_url('index.php'); ?>";
											break;
										case "abort":
											alert("Une erreur est survenu");
											break;
										case "error":
											alert(res.message);
									}
								}
							});
						});
					});
				</script>
			</div>
		</div>
	</div>
</div>