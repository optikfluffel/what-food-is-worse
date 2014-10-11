$(document).ready(function () {
  // auto active
  $('a[href="' + this.location.pathname + '"]').parent().addClass('active');

  // show login
  $('.toggle-forms a.login').click(function(event) {
    event.preventDefault();
    $(this).parents('.toggle-forms').hide();
    $('.navbar-form.login').show();
  });
  $('.navbar-form.login .reset').click(function(event) {
    $(this).parents('.navbar-form').hide();
    $('#main-nav .toggle-forms').show();
  });

  // show register
  $('.toggle-forms a.register').click(function(event) {
    event.preventDefault();
    $(this).parents('.toggle-forms').hide();
    $('.navbar-form.register').show();
  });
  $('.navbar-form.register .reset').click(function(event) {
    $(this).parents('.navbar-form').hide();
    $('#main-nav .toggle-forms').show();
  });
});
