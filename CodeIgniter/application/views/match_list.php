<?php
	if (!isset($quiz_and_matches)) {
		echo "
			<div class=\"row\">
				<div class=\"col-12 grid-margin\">
					<div class=\"card\">
						<div class=\"card-body\">
							<p class=\"text-center font-weight-bold\">Il n'y a pas de quiz ni de match pour le moment</p>
						</div>
					</div>
				</div>
			</div>
		";
	} else {
		echo "
			<div class=\"row\">
				<div class=\"col-12 grid-margin\">
					<div class=\"card\">
						<div class=\"card-body\">
							<h4 class=\"card-title\">Liste des quiz</h4>
								<div class=\"table-responsive\">
									<table class=\"table\">
										<thead>
											<tr>
												<th>Titre du quiz</th>
												<th>Auteur du quiz</th>
											</tr>
										</thead>
										<tbody>
		";
							
		$quiz_ids = array();

		foreach ($quiz_and_matches as $quiz) {
			if (!in_array($quiz['quiz_id'], $quiz_ids)) {
				echo "
					<tr>
						<td class=\"text-wrap\">".$quiz['quiz_title']."</td>
						<td>".$quiz['man_pseudo_quiz']."</td>
					</tr>
				";

				array_push($quiz_ids, $quiz['quiz_id']);
			}
		}

		echo "
								</tbody>
							</table>
						</div>		
						</div>
					</div>
				</div>
			</div>
			<div class=\"row\">
				<div class=\"col-12 grid-margin\">
					<div class=\"card\">
						<div class=\"card-body\">
							<div class=\"container-fluid p-0 m-0\">
								<h4 class=\"card-title d-inline\">Liste des matches</h4>
								<button type=\"button\" class=\"d-inline float-right btn btn-outline-warning\" id=\"matchCreateBtn\">Créer un match</button>
							</div>
		";
						
		$match_found = false;

		foreach ($quiz_and_matches as $match) {
			if ($match['match_id'] != null) {
				$match_found = true;
				break;
			}
		}

		if ($match_found == false) {
			echo "<p class=\"text-center font-weight-bold\">Il n'y a pas de match associé à un quiz pour le moment</p>";
		} else {
			echo "
				<div class=\"table-responsive\">
					<table class=\"table table-hover\" id=\"tableMatches\">
						<thead>
							<tr>
								<th>Titre du quiz</th>
								<th>Auteur du quiz</th>
								<th>Titre du match</th>
								<th>Code</th>
								<th>Date de début</th>
								<th>Date de fin</th>
								<th>Auteur du match</th>
								<th></th>
							</tr>
						</thead>
						<tbody>
			";

			foreach ($quiz_and_matches as $match) {
				if ($match['match_id'] != null) {
					echo "
						<tr class=\"matchRow\" data-mcode=\"".$match['match_code']."\" data-mid=\"".$match['match_id']."\">
							<td class=\"text-wrap\">".$match['quiz_title']."</td>
							<td>".$match['man_pseudo_quiz']."</td>
							<td class=\"text-wrap\">".$match['match_title']."</td>
							<td>".$match['match_code']."</td>
							<td class=\"text-wrap date\">".$match['match_start_date']."</td>
							<td class=\"text-wrap date\">".$match['match_end_date']."</td>
							<td>".$match['man_pseudo']."</td>
							<td>
					";

					if ($match['man_id'] == $_SESSION['id'] || $_SESSION['role'] == "A") {
						echo "
							<button class=\"btn btn-link p-0 matchDelete\" role=\"link\">
								<span class=\"menu-icon\">
									<i class=\"mdi mdi-delete icon-md text-danger\"></i>
								</span>
							</button>
							<button class=\"btn btn-link p-0 matchChangeStatus\" role=\"link\">
								<span class=\"menu-icon\">
						";

						if ($match['match_enabled'] == true) {
							echo "<i class=\"mdi mdi-lock-open icon-md text-success\"></i>";
						} else {
							echo "<i class=\"mdi mdi-lock icon-md text-danger\"></i>";
						}

						echo "
								</span>
							</button>
							<button class=\"btn btn-link p-0 matchReset\" role=\"link\">
								<span class=\"menu-icon\">
									<i class=\"mdi mdi-autorenew icon-md text-info\"></i>
								</span>
							</button>
						";
					}

					echo "
							</td>
						</tr>
					";
				}
			}

			echo "
										</tbody>
									</table>
								</div>
			";
		}

		echo "
			<div class=\"modal fade\" id=\"matchCreateModal\">
				<div class=\"modal-dialog modal-dialog-centered\">
					<div class=\"modal-content\">
						<div class=\"modal-header\">
							<h5 class=\"modal-title\">Créer un match</h5>
							<button type=\"button\" class=\"close\" data-dismiss=\"modal\">
								<span>&times;</span>
							</button>
						</div>
						<div class=\"modal-body\">
							<form class=\"createMatchForm\">
                                <div class=\"form-group\">
                                    <label>Titre *</label>
                                    <input type=\"text\" class=\"form-control p_input text-light\" id=\"mTitle\" name=\"mTitle\" minlength=\"3\" maxlength=\"200\">
                                </div>
                                <div class=\"form-group\">
                                	<label>Quiz *</label>
                                	<select class=\"form-control text-light\" id=\"mQuiz\" name=\"mQuiz\">
								    	<option selected>Veuillez sélectionner un quiz</option>
		";

		$quiz_ids = array();

		foreach ($quiz_and_matches as $quiz) {
			if (!in_array($quiz['quiz_id'], $quiz_ids)) {
				echo "<option value=\"".$quiz['quiz_id']."\">".$quiz['quiz_title']." - ".$quiz['man_pseudo_quiz']."</option>";

				array_push($quiz_ids, $quiz['quiz_id']);
			}
		}

		$min_date_start = date("Y-m-d");
		$min_date_end = date("Y-m-d", strtotime("+1 day", strtotime($min_date_start)));

		echo "
												  </select>
				                                </div>
				                                <div class=\"form-row align-items-center\">
				                                	<div class=\"col-6 form-group\">
					                                    <label>Date de début</label>
					                                    <input type=\"date\" class=\"form-control\" id=\"mDateStart\" name=\"mDateStart\" min=\"".$min_date_start."\">
					                                </div>
					                                <div class=\"col-6 form-group\">
					                                    <label>Date de fin</label>
					                                    <input type=\"date\" class=\"form-control\" id=\"mDateEnd\" name=\"mDateEnd\" min=\"".$min_date_end."\">
					                                </div>
				                                </div>
				                                <div class=\"form-check\">
			                                        <label class=\"form-check-label text-light\">
			                                        	<input type=\"checkbox\" class=\"form-check-input \" id=\"mShowAnswers\" name=\"mShowAnswers\"> Afficher les réponses
			                                        </label>
			                                    </div>
			                                    <div class=\"form-check\">
			                                        <label class=\"form-check-label text-light\">
			                                        	<input type=\"checkbox\" class=\"form-check-input \" id=\"mEnabled\" name=\"mEnabled\" checked> Activé
			                                        </label>
			                                    </div>
				                                <div class=\"text-center\">
				                                    <button type=\"submit\" class=\"btn btn-primary btn-block enter-btn\">Créer</button>
				                                </div>
				                            </form>
										</div>
									</div>
								</div>
							</div>

							<script>
								$(document).ready(() => {
									$(\"#matchCreateBtn\").click(event => {
										$(\"#mTitle\").val(\"\");
										$(\"#mShowAnswers\").prop(\"checked\", false);
										$(\"#mEnabled\").prop(\"checked\", true);
										$(\"#mQuiz\").prop(\"selectedIndex\", 0).change();
										$(\"#mDateStart\").val(\"\");
										$(\"#mDateEnd\").val(\"\");
										$(\"#matchCreateModal\").modal(\"show\");
									});

									$(\".createMatchForm\").submit(event => {
										event.preventDefault();

										var data = {
											mTitle: $(\"#mTitle\").val(),
											mShowAnswers: ($(\"#mShowAnswers\").is(\":checked\") ? 1 : 0),
											mEnabled: ($(\"#mEnabled\").is(\":checked\") ? 1 : 0),
											mQuiz: $(\"#mQuiz option:selected\").val(),
											mDateStart: $(\"#mDateStart\").val(),
											mDateEnd: $(\"#mDateEnd\").val()
										};

										$.ajax({
											type: \"POST\",
											url: \"".base_url('index.php/match/create')."\",
											data: data,
											dataType: \"json\",
											success: res => {
												switch (res.status) {
													case \"success\":
														$(\"#tableMatches\").append(\"<tr class='matchRow' data-mcode='\" + res.data.mCode + \"' data-mid='\" + res.data.mId + \"'><td class='text-wrap'>\" + res.data.qTitle + \"</td><td>\" + res.data.qAutor + \"</td><td class='text-wrap'>\" + data.mTitle + \"</td><td>\" + res.data.mCode + \"</td><td class='text-wrap date'>\" + data.mDateStart + \"</td><td class='text-wrap date'>\" + data.mDateStart + \"</td><td>\" + res.data.mAutor + \"</td><td><button class='btn btn-link p-0 matchDelete' role='link'><span class='menu-icon'><i class='mdi mdi-delete icon-md text-danger'></i></span></button><button class='btn btn-link p-0 matchChangeStatus' role='link'><span class='menu-icon'>\" + (data.mEnabled == 1 ? \"<i class='mdi mdi-lock-open icon-md text-success'></i>\" : \"<i class='mdi mdi-lock icon-md text-danger'></i>\") + \"</span></button><button class='btn btn-link p-0 matchReset' role='link'><span class='menu-icon'><i class='mdi mdi-autorenew icon-md text-info'></i></span></button></td></tr>\");
														$(\"#matchCreateModal\").modal(\"hide\");
														break;
													case \"abort\":
														alert(\"Le quiz sélectionne est incomplet ou des informations sont invalides\");
														break;
													case \"error\":
														alert(res.message);
												}
											}
										});
									});

									$(\"#tableMatches tbody\").on(\"click\", \".matchRow\", event => {
										var dataset = event.currentTarget.dataset;
										window.location = \"".base_url("index.php/match/info/")."\" + dataset.mcode + \"/\" + dataset.mid;
									});

									$(\"#tableMatches tbody\").on(\"click\", \".matchDelete\", event => {
										event.stopPropagation();

										var tr = event.target.closest(\"tr\");
										var data = {
											mCode: tr.dataset.mcode,
											mId: tr.dataset.mid
										};

										$.ajax({
											type: \"POST\",
											url: \"".base_url('index.php/match/delete')."\",
											data: data,
											dataType: \"json\",
											success: res => {
												switch (res.status) {
													case \"success\":
														tr.remove();
														break;
													case \"abort\":
														alert(\"Ce match n'existe pas\");
														break;
													case \"error\":
														alert(res.message);
												}
											}
										});
									});

									$(\"#tableMatches tbody\").on(\"click\", \".matchChangeStatus\", event => {
										event.stopPropagation();

										var tr = event.target.closest(\"tr\");
										var data = {
											mCode: tr.dataset.mcode,
											mId: tr.dataset.mid
										};

										$.ajax({
											type: \"POST\",
											url: \"".base_url('index.php/match/change_status')."\",
											data: data,
											dataType: \"json\",
											success: res => {
												switch (res.status) {
													case \"success\":
														$(event.target).closest(\"i\").toggleClass(\"mdi-lock-open text-success\").toggleClass(\"mdi-lock text-danger\");
														break;
													case \"abort\":
														alert(\"Ce match n'existe pas\");
														break;
													case \"error\":
														alert(res.message);
												}
											}
										});
									});

									$(\"#tableMatches tbody\").on(\"click\", \".matchReset\", event => {
										event.stopPropagation();

										var tr = event.target.closest(\"tr\");
										var data = {
											mCode: tr.dataset.mcode,
											mId: tr.dataset.mid
										};

										$.ajax({
											type: \"POST\",
											url: \"".base_url('index.php/match/reset')."\",
											data: data,
											dataType: \"json\",
											success: res => {
												switch (res.status) {
													case \"success\":
														$(tr).children(\".date\").empty();
														alert(\"Le match a été réinitialisé\");
														break;
													case \"abort\":
														alert(\"Ce match n'existe pas\");
														break;
													case \"error\":
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
		";
	}
?>