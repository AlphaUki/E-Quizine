<!DOCTYPE html>
<html>
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1, shrink-to-fit=no">
    <title>Accueil</title>
    <link rel="stylesheet" href="<?php echo base_url(); ?>assets/vendors/mdi/css/materialdesignicons.min.css">
    <link rel="stylesheet" href="<?php echo base_url(); ?>assets/vendors/css/vendor.bundle.base.css">
    <link rel="stylesheet" href="<?php echo base_url(); ?>assets/vendors/jvectormap/jquery-jvectormap.css">
    <link rel="stylesheet" href="<?php echo base_url(); ?>assets/vendors/flag-icon-css/css/flag-icon.min.css">
    <link rel="stylesheet" href="<?php echo base_url(); ?>assets/vendors/owl-carousel-2/owl.carousel.min.css">
    <link rel="stylesheet" href="<?php echo base_url(); ?>assets/vendors/owl-carousel-2/owl.theme.default.min.css">
    <link rel="stylesheet" href="<?php echo base_url(); ?>assets/css/style.css">
    <link rel="shortcut icon" href="<?php echo base_url(); ?>assets/images/favicon.png" />
    <script type="text/javascript" src="https://ajax.googleapis.com/ajax/libs/jquery/3.6.1/jquery.min.js"></script>
</head>
<body>
	<div class="container-scroller">
		<!-- partial:partials/_sidebar.html -->
		<nav class="sidebar sidebar-offcanvas" id="sidebar">
			<div class="sidebar-brand-wrapper d-none d-lg-flex align-items-center justify-content-center fixed-top">
				<a class="sidebar-brand brand-logo" href="<?php echo base_url('index.php'); ?>"><img src="<?php echo base_url(); ?>assets/images/logo.svg" alt="logo" /></a>
				<a class="sidebar-brand brand-logo-mini" href="<?php echo base_url('index.php'); ?>"><img src="<?php echo base_url(); ?>assets/images/logo-mini.svg" alt="logo" /></a>
			</div>
			<ul class="nav">
				<li class="nav-item nav-category">
					<span class="nav-link">Navigation</span>
				</li>
				<?php
					echo "
						<li class=\"nav-item menu-items\">
							<a class=\"nav-link\" href=\"".base_url("index.php")."\">
								<span class=\"menu-icon\">
									<i class=\"mdi mdi-home\"></i>
								</span>
								<span class=\"menu-title\">Accueil</span>
							</a>
						</li>
					";
					if ($_SESSION['role'] == "A") {
						echo "
							<li class=\"nav-item menu-items\">
								<a class=\"nav-link\" href=\"".base_url("index.php/manager/users")."\">
									<span class=\"menu-icon\">
										<i class=\"mdi mdi-account-multiple\"></i>
									</span>
									<span class=\"menu-title\">Utilisateurs</span>
								</a>
							</li>
						";
					} else {
						echo "
							<li class=\"nav-item menu-items\">
								<a class=\"nav-link\" href=\"".base_url("index.php/match/list")."\">
									<span class=\"menu-icon\">
										<i class=\"mdi mdi-sword-cross\"></i>
									</span>
									<span class=\"menu-title\">Matches</span>
								</a>
							</li>
						";
					}
				?>
			</ul>
		</nav>
		<!-- partial -->
		<div class="container-fluid page-body-wrapper">
			<nav class="navbar p-0 fixed-top d-flex flex-row">
				<div class="navbar-brand-wrapper d-flex d-lg-none align-items-center justify-content-center">
					<a class="navbar-brand brand-logo-mini" href="<?php echo base_url('index.php'); ?>"><img src="<?php echo base_url(); ?>assets/images/logo-mini.svg" alt="logo" /></a>
				</div>
				<div class="navbar-menu-wrapper flex-grow d-flex align-items-stretch">
					<button class="navbar-toggler navbar-toggler align-self-center" type="button" data-toggle="minimize">
					<span class="mdi mdi-menu"></span>
					</button>
					<ul class="navbar-nav navbar-nav-right">
						<li class="nav-item dropdown">
							<a class="nav-link" id="profileDropdown" href="#" data-toggle="dropdown">
								<div class="navbar-profile">
									<p class="mb-0 d-none d-sm-block navbar-profile-name"><?php echo $_SESSION['pseudo']; ?></p>
									<i class="mdi mdi-menu-down d-none d-sm-block"></i>
								</div>
							</a>
							<div class="dropdown-menu dropdown-menu-right navbar-dropdown preview-list" aria-labelledby="profileDropdown">
								<div class="dropdown-divider"></div>
								<a class="dropdown-item preview-item" href="<?php echo base_url('index.php/manager/details'); ?>">
									<div class="preview-thumbnail">
										<div class="preview-icon bg-dark rounded-circle">
											<i class="mdi mdi-settings text-success"></i>
										</div>
									</div>
									<div class="preview-item-content">
										<p class="preview-subject mb-1">Profil</p>
									</div>
								</a>
								<div class="dropdown-divider"></div>
								<a class="dropdown-item preview-item" id="btnLogout">
									<div class="preview-thumbnail">
										<div class="preview-icon bg-dark rounded-circle">
											<i class="mdi mdi-logout text-danger"></i>
										</div>
									</div>
									<div class="preview-item-content">
										<p class="preview-subject mb-1">Se déconnecter</p>
									</div>
								</a>

								<script>
									$(document).ready(() => {
										$("#btnLogout").click(() => {
											$.ajax({
												type: "POST",
												url: "<?php echo base_url('index.php/manager/logout'); ?>",
												dataType: 'json',
												success: res => {
													switch (res.status) {
														case "success":
															window.location.href = "<?php echo base_url('index.php'); ?>";
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
						</li>
					</ul>
					<button class="navbar-toggler navbar-toggler-right d-lg-none align-self-center" type="button" data-toggle="offcanvas">
					<span class="mdi mdi-format-line-spacing"></span>
					</button>
				</div>
			</nav>

			<!-- partial -->
			<div class="main-panel">
				<div class="content-wrapper">