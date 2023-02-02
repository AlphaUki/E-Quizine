<div class="row">
	<div class="col-12 grid-margin">
		<div class="card corona-gradient-card">
			<div class="card-body col-lg-4 mx-auto px-5 py-5">
				<form class="check_code">
					<div class="form-group">
						<input type="text" class="form-control p_input" placeholder="Code du match" id="mCode" name="mCode">
					</div>
					<div class="text-center">
						<button type="submit" class="btn btn-primary btn-block">Rejoindre</button>
					</div>
				</form>
				<div class="modal fade" id="modalMulMatches">
					<div class="modal-dialog modal-dialog-centered">
						<div class="modal-content">
							<div class="modal-header">
								<h5 class="modal-title">Matches associés</h5>
								<button type="button" class="close" data-dismiss="modal">
									<span>&times;</span>
								</button>
							</div>
							<div class="modal-body">
								<div class="table-responsive">
									<table class="table table-hover">
										<thead>
											<tr>
												<th>Titre</th>
												<th>Auteur</th>
											</tr>
										</thead>
										<tbody id="simMatches">
										</tbody>
									</table>
								</div>
							</div>
						</div>
					</div>
				</div>

				<div class="modal fade" id="modalPlayerPseudo">
					<div class="modal-dialog modal-dialog-centered">
						<div class="modal-content">
							<div class="modal-header">
								<h5 class="modal-title">Choisissez votre pseudo</h5>
								<button type="button" class="close" data-dismiss="modal">
									<span>&times;</span>
								</button>
							</div>
							<div class="modal-body">
								<form class="check_pseudo">
									<div class="form-group">
										<input type="text" class="form-control p_input" placeholder="Pseudo" id="pPseudo" name="pPseudo">
										<input type="hidden" id="mId" name="mId" value="">
									</div>
									<div class="text-center">
										<button type="submit" class="btn btn-primary btn-block">Rejoindre</button>
									</div>
								</form>
							</div>
						</div>
					</div>
				</div>

				<script>
					$(document).ready(() => {
						$(".check_code").submit(event => {
							event.preventDefault();
							
							$.ajax({
								type: "POST",
								url: "<?php echo base_url('index.php/match/check_code'); ?>",
								data: { mCode: $("#mCode").val() },
								dataType: 'json',
								success: res => {
									switch (res.status) {
										case "success":
											var matches = res.data;
											if (matches.length == 1) {
												$("#mId").val(matches[0][0]);
												$("#modalPlayerPseudo").modal("show");
											} else {
												$("#simMatches").empty();
												matches.forEach(match => {
													$("#simMatches").append(
														"<tr data-mid=\"" + match[0] + "\">\
															<td class=\"text-wrap\">" + match[1] + "</td>\
															<td>" + match[2] + "</td>\
														</tr>"
													);
												});
												$("#simMatches").click(event => {
													$("#mId").val(event.target.closest('tr').dataset.mid);
													$("#modalMulMatches").modal("hide");
													$("#modalPlayerPseudo").modal("show");
												});
												$("#modalMulMatches").modal("show");
											}
											break;
										case "abort":
											alert("Ce match n'existe pas");
											break;
										case "error":
											alert(res.message);
									}
								}
							});
						});

						$(".check_pseudo").submit(event => {
							event.preventDefault();
							
							var data = {
								pPseudo: $("#pPseudo").val(),
								mId: $("#mId").val()
							};

							var mCode = $("#mCode").val();

							$.ajax({
								type: "POST",
								url: "<?php echo base_url('index.php/match/check_pseudo'); ?>",
								data: data,
								dataType: 'json',
								success: res => {
									switch (res.status) {
										case "success":
											window.location.href = "<?php echo base_url('index.php/match/show/'); ?>" + mCode + "/" + data.mId;
											break;
										case "abort":
											alert("Ce pseudo est déjà utilisé");
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