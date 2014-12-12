/*                           */
/*  javacscript for new_poll */
/*                           */
//***************************script for closing date/time***************************
    $(document).ready(function()
    {
        loadDateTimeHtml();
        var defaultCloseDate = new Date();
        defaultCloseDate.setDate(defaultCloseDate.getDate() + 1);
        defaultCloseDate.setHours(defaultCloseDate.getHours() + 1);
        defaultCloseDate.setMinutes(0);
        defaultCloseDate.setSeconds(0);
        var hours12 = defaultCloseDate.getHours();
        if (hours12 % 12 == 0)
            $("#hour").val(12);
        else
            $("#hour").val(hours12 % 12);
        $("#minute").val(defaultCloseDate.getMinutes());
        if (defaultCloseDate.getHours() < 12)
            $("#ampm").val("AM");
        else
            $("#ampm").val("PM");
        $("#close-date-picker").datepicker({minDate:0});
        $("#close-date-picker").datepicker("setDate", defaultCloseDate);

        var closeDate = new Date(defaultCloseDate);
        $("#closedate").val(closeDate.toUTCString());

        $("#close-date-picker").change(function()
        {
            var currentDatePicker = $(this).datepicker("getDate");
            closeDate.setFullYear(currentDatePicker.getFullYear());
            closeDate.setMonth(currentDatePicker.getMonth());
            closeDate.setDate(currentDatePicker.getDate());
            $("#closedate").val(closeDate.toUTCString());
        });

        //$("#minute").change(function()
        //{
        //    closeDate.setMinutes($("#minute").val());
        //    $("#closedate").val(closeDate.toUTCString());
        //});

        $("#hour").change(function()
        {
            changeHour();
        });

        $("#ampm").change(function()
        {
            changeHour();
        });

        function changeHour()
        {
            var hourChange = parseInt($("#hour").val()) % 12;
            if ($("#ampm").val() == "PM")
                hourChange += 12;
            closeDate.setHours(hourChange);
            $("#closedate").val(closeDate.toUTCString());
        }

        $("#unset-time-btn").click(function()
        {
            $("#unset-time-btn").addClass("disabled");
            $("#set-time-btn").removeClass("disabled");
            $("#closedate").val("");
            $("#close-date-picker").datepicker("disable");
            $("#hour").prop("disabled", true);
            $("#ampm").prop("disabled", true);
        });

        $("#set-time-btn").click(function()
        {
            $("#set-time-btn").addClass("disabled");
            $("#unset-time-btn").removeClass("disabled");
            $("#closedate").val(closeDate.toUTCString());
            $("#close-date-picker").datepicker("enable");
            $("#hour").prop("disabled", false);
            $("#ampm").prop("disabled", false);
        });
    });

    function loadDateTimeHtml()
    {
        var hourHtml = "";
        //var minuteHtml = "";
        var ampmHtml = "";

        for (var i = 1; i <= 12; i++)
        {
            hourHtml += "<option value='" + i + "'>" + i + "</option>";
        }
        document.getElementById("hour").innerHTML = hourHtml;

        //for (var i = 0; i < 60; i++)
        //{
        //    minuteHtml += "<option value='" + i +"'> :" + ("0" + i).slice(-2) + "</option>";
        //}
        //document.getElementById("minute").innerHTML = minuteHtml;

        ampmHtml += "<option value='AM'>AM</option>";
        ampmHtml += "<option value='PM'>PM</option>";
        document.getElementById("ampm").innerHTML = ampmHtml;
    }
//***************************script for options***************************
    function displayOptions()
    {
        var optionsHtml = "";
        var num = parseInt(document.getElementById("numOfOptions").value);
        for (var i = 0; i < num; i++)
        {
            optionsHtml += "<div class='form-group'>";
            optionsHtml += "<label for='option" + i + "' class='col-sm-4 control-label'>Option " + (i+1) + "</label>";
            optionsHtml += "<div class='col-sm-8'>";
            optionsHtml += "<input type='text' class='form-control' name='option[]' id='option" + i + "' maxlength='50'>";
            optionsHtml += "</div>";
            optionsHtml += "<div class='col-sm-6'></div>";
            optionsHtml += "</div>";
        }
        document.getElementById("options").innerHTML = optionsHtml;
    }

    $(document).ready(function()
    {
        displayOptions();

        $("#numOfOptions").change(function()
        {
            var num = parseInt(document.getElementById("numOfOptions").value);
            if (num < 2 || isNaN(num))
            {
                document.getElementById("numOfOptions").value = 2;
            }
            displayOptions();
        });
        $("#plus-btn-options").click(function()
        {
            var num = parseInt(document.getElementById("numOfOptions").value);
            document.getElementById("numOfOptions").value = num + 1;
            displayOptions();
        });
        $("#minus-btn-options").click(function()
        {
            var num = parseInt(document.getElementById("numOfOptions").value);
            if (num > 2)
            {
                document.getElementById("numOfOptions").value = num - 1;
                displayOptions();
            }
        });
    });


//***************************script for participants***************************
    function displayEmails()
    {
        var emailsHtml = "";
        var num = parseInt(document.getElementById("numOfEmails").value);
        for (var i = 0; i < num; i++)
        {
            emailsHtml += "<div class='form-group'>";
            emailsHtml += "<label for='email" + i + "' class='col-sm-4 control-label'>Email " + (i+1) + "</label>";
            emailsHtml += "<div class='col-sm-8'>";
            emailsHtml += "<input type='email' class='form-control' name='email[]' id='email" + i + "'>";
            emailsHtml += "</div>";
            emailsHtml += "<div class='col-sm-6'></div>";
            emailsHtml += "</div>";
        }
        document.getElementById("emails").innerHTML = emailsHtml;
    }

    $(document).ready(function()
    {
        displayEmails();

        $("#numOfEmails").change(function()
        {
            var num = parseInt(document.getElementById("numOfEmails").value);
            if (num < 1 || isNaN(num))
            {
                document.getElementById("numOfEmails").value = 1;
            }
            displayEmails();
        });
        $("#plus-btn-emails").click(function()
        {
            var num = parseInt(document.getElementById("numOfEmails").value);
            document.getElementById("numOfEmails").value = num + 1;
            displayEmails();
        });
        $("#minus-btn-emails").click(function()
        {
            var num = parseInt(document.getElementById("numOfEmails").value);
            if (num > 1)
            {
                document.getElementById("numOfEmails").value = num - 1;
                displayEmails();
            }
        });
    });
