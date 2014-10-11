$(document).ready(function () {
  // auto active
  $('a[href="' + this.location.pathname + '"]').parent().addClass('active');

  function enableFancyLoginAndRegisterNavbarForm(type) {
    // show
    $('.toggle-forms a.' + type).click(function(event) {
      event.preventDefault();
      $(this).parents('.toggle-forms').hide();
      $('.navbar-form.' + type).show();
      $('.navbar-form.' + type).find('input[name="username"]').focus();
    });

    // cancel
    $('.navbar-form.' + type + ' .reset').click(function(event) {
      $(this).parents('.navbar-form').hide();
      $('#main-nav .toggle-forms').show();
    });
  };

  enableFancyLoginAndRegisterNavbarForm('login');
  enableFancyLoginAndRegisterNavbarForm('register');
});
