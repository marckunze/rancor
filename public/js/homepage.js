/*                           */
/*  javacscript for new_poll */
/*                           */
$(document).ready(function()
{
//**************************Change support script*************************
    $("#change-email-panel").hide();
    $("#change-password-panel").hide();

    $("#change-email-btn").click(function()
    {
        $("#change-password-panel").hide();
        if ($("#change-email-panel").css("display") == "none")
        {
            showChangeEmail();
            hideChangePassword();
        }
        else
        {
            hideChangeEmail();
        }
    });
    $("#change-password-btn").click(function()
    {
        $("#change-email-panel").hide();
        if ($("#change-password-panel").css("display") == "none")
        {
            showChangePassword();
            hideChangeEmail();
        }
        else
        {
            hideChangePassword();
        }
    });

    function showChangeEmail()
    {
        $("#change-email-panel").slideDown();
        $("#change-email-btn > i").removeClass("glyphicon-chevron-down");
        $("#change-email-btn > i").addClass("glyphicon-chevron-up");
    }
    function hideChangeEmail()
    {
        $("#change-email-panel").slideUp();
        $("#change-email-btn > i").removeClass("glyphicon-chevron-up");
        $("#change-email-btn > i").addClass("glyphicon-chevron-down");
    }
    function showChangePassword()
    {
        $("#change-password-panel").slideDown();
        $("#change-password-btn > i").removeClass("glyphicon-chevron-down");
        $("#change-password-btn > i").addClass("glyphicon-chevron-up");
    }
    function hideChangePassword()
    {
        $("#change-password-panel").slideUp();
        $("#change-password-btn > i").removeClass("glyphicon-chevron-up");
        $("#change-password-btn > i").addClass("glyphicon-chevron-down");
    }
});
