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
                            <form class="update_manager">
                                <div class="form-group">
                                    <label>Nom</label>
                                    <input type="text" class="form-control p_input" id="pflLastNameNew" name="pflLastNameNew" placeholder="<?php echo $_SESSION['last_name']; ?>">
                                </div>
                                <div class="form-group">
                                    <label>Prénom</label>
                                    <input type="text" class="form-control p_input" id="pflFirtNameNew" name="pflFirtNameNew" placeholder="<?php echo $_SESSION['first_name']; ?>">
                                </div>
                                <div class="form-group">
                                    <label>Mot de passe</label>
                                    <input type="password" class="form-control p_input" id="manPw" name="manPw">
                                </div>
                                <div class="form-group">
                                    <label>Nouveau mot de passe</label>
                                    <input type="password" class="form-control p_input" id="manPwNew" name="manPwNew">
                                </div>
                                <div class="form-group">
                                    <label>Confirmer le mot de passe</label>
                                    <input type="password" class="form-control p_input" id="manPwConfirm" name="manPwConfirm">
                                </div>
                                <div class="row">
                                    <div class="col-sm-6">
                                        <button type="button" class="btn btn-secondary btn-lg btn-block" onclick="<?php echo 'window.location.href = \''.base_url('index.php').'\''; ?>">Annuler</button>
                                    </div>
                                    <div class="col-sm-6">
                                        <button type="submit" class="btn btn-primary btn-lg btn-block">Enregistrer</button>
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
    <script>
        $(document).ready(() => {
            $(".update_manager").submit(event => {
                event.preventDefault();

                $.ajax({
                    type: "POST",
                    url: "<?php echo base_url('index.php/manager/update'); ?>",
                    data : {
                        pflLastNameNew: $("#pflLastNameNew").val(),
                        pflFirtNameNew: $("#pflFirtNameNew").val(),
                        manPw: $("#manPw").val(),
                        manPwNew: $("#manPwNew").val(),
                        manPwConfirm: $("#manPwConfirm").val()
                    },
                    dataType: 'json',
                    success: res => {
                        switch (res.status) {
                            case "success":
                                window.location.href = "<?php echo base_url('index.php'); ?>";
                                break;
                            case "abort":
                                alert("Le nouveau mot de passe et le mot de passe de confirmation ne correspondent pas");
                                break;
                            case "error":
                                alert(res.message);
                        }
                    }
                });
            });
        });
    </script>
    <script src="<?php echo base_url(); ?>assets/vendors/js/vendor.bundle.base.js"></script>
    <script src="<?php echo base_url(); ?>assets/js/off-canvas.js"></script>
    <script src="<?php echo base_url(); ?>assets/js/hoverable-collapse.js"></script>
    <script src="<?php echo base_url(); ?>assets/js/misc.js"></script>
    <script src="<?php echo base_url(); ?>assets/js/settings.js"></script>
    <script src="<?php echo base_url(); ?>assets/js/todolist.js"></script>
</body>
</html>