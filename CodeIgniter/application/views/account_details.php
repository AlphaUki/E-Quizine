<!DOCTYPE html>
<html>
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1, shrink-to-fit=no">
    <title>Profil</title>
    <link rel="stylesheet" href="<?php echo base_url(); ?>assets/vendors/mdi/css/materialdesignicons.min.css">
    <link rel="stylesheet" href="<?php echo base_url(); ?>assets/vendors/css/vendor.bundle.base.css">
    <link rel="stylesheet" href="<?php echo base_url(); ?>assets/css/style.css">
    <link rel="shortcut icon" href="<?php echo base_url(); ?>assets/images/favicon.png" />
    <script type="text/javascript" src="https://ajax.googleapis.com/ajax/libs/jquery/3.6.1/jquery.min.js"></script>
</head>
<body>
    <div class="container-scroller">
        <div class="container-fluid page-body-wrapper full-page-wrapper">
            <div class="row w-100 m-0">
                <div class="content-wrapper full-page-wrapper d-flex align-items-center auth login-bg">
                    <div class="card col-lg-4 mx-auto">
                        <div class="card-body px-5 py-5">
                            <h3 class="card-title text-left mb-3">Profil</h3>
                            <form class="update_manager">
                                <div class="form-group">
                                    <label>Pseudo</label>
                                    <input type="text" class="form-control p_input" name="manPseudo" placeholder="<?php echo $_SESSION['pseudo']; ?>" disabled>
                                </div>
                                <div class="form-group">
                                    <label>Nom</label>
                                    <input type="text" class="form-control p_input" name="pflLastName" placeholder="<?php echo $_SESSION['last_name']; ?>" disabled>
                                </div>
                                <div class="form-group">
                                    <label>Prénom</label>
                                    <input type="text" class="form-control p_input" name="pflFirtName" placeholder="<?php echo $_SESSION['first_name']; ?>" disabled>
                                </div>
                                <div class="row">
                                    <div class="col-sm-6">
                                        <button type="button" class="btn btn-secondary btn-lg btn-block" onclick="<?php echo 'window.location.href = \''.base_url('index.php').'\''; ?>">Annuler</button>
                                    </div>
                                    <div class="col-sm-6">
                                        <button type="button" class="btn btn-primary btn-lg btn-block" onclick="<?php echo 'window.location.href = \''.base_url('index.php/manager/update').'\''; ?>">Modifier</button>
                                    </div>
                                </div>
                            </form>
                        </div>
                    </div>
                </div>
                <!-- content-wrapper ends -->
            </div>
            <!-- row ends -->
        </div>
        <!-- page-body-wrapper ends -->
    </div>
    <!-- container-scroller -->
    <script src="<?php echo base_url(); ?>assets/vendors/js/vendor.bundle.base.js"></script>
    <script src="<?php echo base_url(); ?>assets/js/off-canvas.js"></script>
    <script src="<?php echo base_url(); ?>assets/js/hoverable-collapse.js"></script>
    <script src="<?php echo base_url(); ?>assets/js/misc.js"></script>
    <script src="<?php echo base_url(); ?>assets/js/settings.js"></script>
    <script src="<?php echo base_url(); ?>assets/js/todolist.js"></script>
</body>
</html>