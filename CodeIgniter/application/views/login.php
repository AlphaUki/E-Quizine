<!DOCTYPE html>
<html>
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1, shrink-to-fit=no">
    <title>Login</title>
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
                            <h3 class="card-title text-left mb-3">Login</h3>
                            <form class="check_login">
                                <div class="form-group">
                                    <label>Pseudo *</label>
                                    <input type="text" class="form-control p_input" id="manPseudo" name="manPseudo">
                                </div>
                                <div class="form-group">
                                    <label>Password *</label>
                                    <input type="password" class="form-control p_input" id="manPw" name="manPw">
                                </div>
                                <div class="form-group d-flex align-items-center justify-content-between">
                                    <div class="form-check">
                                        <label class="form-check-label">
                                        <input type="checkbox" class="form-check-input"> Remember me </label>
                                    </div>
                                </div>
                                <div class="text-center">
                                    <button type="submit" class="btn btn-primary btn-block enter-btn">Login</button>
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
            $(".check_login").submit(event => {
                event.preventDefault();
                
                $.ajax({
                    type: "POST",
                    url: "<?php echo base_url('index.php/manager/login'); ?>",
                    data: { manPseudo: $(".check_login #manPseudo").val(), manPw: $(".check_login #manPw").val() },
                    dataType: 'json',
                    success: res => {
                        switch (res.status) {
                            case "success":
                                window.location.href = "<?php echo base_url('index.php'); ?>";
                                break;
                            case "abort":
                                alert("Ce compte n'existe pas");
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