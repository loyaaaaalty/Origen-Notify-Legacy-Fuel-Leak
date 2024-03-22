const max = 100
let maxFuel = 100
const fuelSound = new Audio('fuel.mp3')
fuelSound.volume = 0.5
eventKeydown()
window.addEventListener('message', function (event) {
    let action = event.data.action

    if(action === 'onPanel') {

        $('body').fadeIn()
        $('.fuelManage').fadeIn(100)
        $("#name").val(0);
        $("#toPay").html("0$");
    } else if (action === 'offPanel') {
        $('body').fadeOut()
        $('.fuelManage').fadeOut(100, function(){
            $(".depotProgbar").css("height","0%");
            $(".newProgbar").css("height","0%");
        })
    } else if (action === 'fuelCompleted') {
        fuelSound.pause()
        $('body').fadeOut()
        $('.fuelManage').fadeOut(100, function(){
            $(".depotProgbar").css("height","0%");
            $(".newProgbar").css("height","0%");
        })
    }

    if (event.data.fuel) {
        maxFuel = max - Math.round(event.data.fuel)
        $(".depotProgbar").css("height", Math.round(event.data.fuel) + "%");
        $(".newProgbar").css("height", "0%");
        // console.log("🚀 ~ file: app.js:14 ~ event.data.fuel", event.data.fuel)
        // Aqui se deberia de poner en la barrita el maximo tambien
    }
    $(".buyButton").off("click").on("click", function(){
       
        if(parseInt($("#name").val())>0){
            $.post("https://origen_fuel/acceptBuy", JSON.stringify({}), function(cb) {
            if(cb === 'ok') {
                fuelSound.play()
                $(".depotProgbar").animate({
                    height: "+=" + $("#name").val()
                }, 8300)
                // $(".newProgbar").animate({
                //     height: "-=" + $("#name").val()
                // }, 8300)
            }
        });
        }
    });
});

function eventKeydown(){
    $(document).keydown(function(event){
        var keycode = (event.keyCode ? event.keyCode : event.which);
        
        if(keycode == '118' || keycode == '27'){
            $.post("https://origen_fuel/close", JSON.stringify({}));
            $('body').fadeOut()
            $('.fuelManage').fadeOut(100)
        }
    });
    $("#name").on("input", function() {
        if ($(this).val() > 100) {
           $("#name").val(100);
        }
        if ($(this).val() > maxFuel) {
            $("#name").val(maxFuel);
        }
        if ($(this).val() < 0) {
            $("#name").val(0);
        }
        if (!$("#name").val()) {
            $("#toPay").html("0$");
            $(".newProgbar").css("height", "0%");
        }
        $(".newProgbar").css("height",  $("#name").val() + "%");
        $.post('https://origen_fuel/getPrice', JSON.stringify({amount: $("#name").val()}), function(cb) {
            $("#toPay").html(cb + "$");
        });
    });
}