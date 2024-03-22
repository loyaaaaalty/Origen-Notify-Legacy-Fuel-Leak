const sound2 = document.getElementById('sound2');
sound2.volume = 0.3;

const s_open = new Audio('https://origennetwork.com/music/v7/openshop.mp3');
const s_close = new Audio('https://origennetwork.com/music/v7/closeshop.mp3');

s_open.volume = 0.5;
s_close.volume = 0.5;

const gta_keys = {
	'~INPUT_WEAPON_SPECIAL_TWO~': 'E',
	'~INPUT_PICKUP~': 'E',
	'~INPUT_CONTEXT~': 'E',
	'~INPUT_DETONATE~': 'G',
	'~INPUT_VEH_FLY_ROLL_LEFT_ONLY~': '4',
	'~INPUT_VEH_FLY_ROLL_RIGHT_ONLY~': '6',
	'~INPUT_VEH_EXIT~': 'F',
	'~INPUT_RELOAD~': 'R',
	'~INPUT_JUMP~': 'ESPACIO',
	'~INPUT_VEH_HEADLIGHT~': 'H'
};

$('document').ready(function () {
	OrigenNotify = {};

	//let lastTime;
	//let lastText;

	let remove_help_notification_i;

	// OrigenNotify.HelpNotification = function (data) {
	//     // if (lastTime == null) {

	//     if (document.querySelector("#helpBar").style.display != "block") {
	//         $("#helpBar").css({ display: "block" });
	//         sound.play();
	//         $("#helpBar").removeClass('help-out').addClass('help-in');
	//         $("#helpText").html(data.text);
	//     } else {
	//         if (remove_help_notification_i != null) {
	//             clearTimeout(remove_help_notification_i);
	//             remove_help_notification_i = null;
	//         }

	//         $("#helpBar").css({ display: "block" });
	//         $("#helpBar").removeClass("help-out").addClass("help-in");

	//         $("#helpText").html(data.text);
	//     }

	//     // } else {
	//     //     lastTime = new Date().getTime();
	//     //     if (data.text != lastText) {
	//     //         $("#helpText").html(data.text);
	//     //         lastText = data.text;
	//     //     }
	//     // }

	//     // setTimeout(function() {
	//     //     if (new Date().getTime() - lastTime >= 800) {
	//     //         $("#helpBar").removeClass("help-in").addClass('help-out');
	//     //         setTimeout(function() {
	//     //             $("#helpBar").css({ display: "none" });
	//     //         }, 300);

	//     //         lastTime = null;
	//     //     }
	//     // }, 1500);
	// };

	// window.addEventListener("click", function(event) {
	window.addEventListener('message', function (event) {
		// event['data'] = { action: 'SendNotification', text: '~y~E~w~ entrar por esta puerta' };
		switch (event.data.action) {
			case 'SetQueueMax':
				Noty.setMaxVisible(event.data.value, event.data.queue);
				break;
			case 'SendNotification':
				if (event.data.text) {
					event.data.text = event.data.text.replace(/~w~/g, '');
					event.data.text = event.data.text.replace(/~b~/g, '');
					event.data.text = event.data.text.replace(/~g~/g, '');
					event.data.text = event.data.text.replace(/~y~/g, '');
					event.data.text = event.data.text.replace(/~o~/g, '');
					event.data.text = event.data.text.replace(/~r~/g, '');
					event.data.text = event.data.text.replace(/~s~/g, '');
					event.data.text = event.data.text.replace(
						/~INPUT_WEAPON_SPECIAL_TWO~/g,
						''
					);
					event.data.text = event.data.text.replace(/~INPUT_PICKUP~/g, '');
					event.data.text = event.data.text.replace(/~INPUT_CONTEXT~/g, '');
					event.data.text = event.data.text.replace(/~INPUT_DETONATE~/g, '');
				}

				let text = event.data.text || 'n/a';

				Noty.setMaxVisible(4, 'general');
				let type = 'alert';
				let layout = 'bottomRight';
				let glitch = 'glitch';

				let style = 'padding:10px;';
				let title = event.data.title;
				let business = event.data.business;
				if (business) {
					if (business == 'open') {
						this.setTimeout(() => {
							s_open.play();
						}, 400);
					} else {
						this.setTimeout(() => {
							s_close.play();
						}, 400);
					}
				} else {
					this.setTimeout(() => {
						sound2.play();
					}, 400);
				}
				if (event.data.type) {
					type = event.data.type;
				}
				if (event.data.layout) {
					layout = event.data.layout;
				}
				let logo =
					'<div class="titulo"><img src="https://i.imgur.com/X3UUGal.png" class="noty__img" /></div>';

				if (layout != 'bottomRight') {
					glitch = '';
					logo = '';
					style = 'border:none !important;';
				}

				if (type == 'disparos') {
					logo =
						'<img width="75" style="padding-right: 7px; opacity: 68%;" src="https://i.imgur.com/GLTsSyA.png">';
				}

				let bell = `<i class="bell fa fa-bell"></i>`;

				if (business) {
					bell = '<i class="bell no-anim fa-solid fa-cart-shopping"></i>';
				}
				const n = new Noty({
					theme: 'origen',
					layout: layout,
					text: `<div class="notification-text">
                    ${bell}
                    <div class="notification-content">
                        <div class="title">${text}</div>

                    </div>
                </div>`,
					queue: event.data.queue || 'general',
					timeout: event.data.timeout || 5000,
					// timeout: 9999999,
					type: type
				});

				n.show();
				break;
			case 'SendHelpNotification':
				if (event.data.text) {
					event.data.text = event.data.text.replace(/~w~/g, '</div>');
					event.data.text = event.data.text.replace(
						/~b~/g,
						"<div class='icon-help'>"
					);
					event.data.text = event.data.text.replace(
						/~g~/g,
						"<div class='icon-help'>"
					);
					event.data.text = event.data.text.replace(
						/~y~/g,
						"<div class='icon-help'>"
					);
					event.data.text = event.data.text.replace(
						/~o~/g,
						"<div class='icon-help'>"
					);
					event.data.text = event.data.text.replace(
						/~r~/g,
						"<div class='icon-help'>"
					);
					event.data.text = event.data.text.replace(
						/~s~/g,
						"<div class='icon-help'>"
					);

					for (let input in gta_keys) {
						event.data.text = event.data.text.replace(
							new RegExp(input),
							`${gta_keys[input]}`
						);
					}
				}

				OrigenNotify.HelpNotification(event.data);
				break;
			case 'RemoveHelpNotification':
				$('#helpBar').removeClass('help-in').addClass('help-out');

				remove_help_notification_i = setTimeout(function () {
					$('#helpBar').css({ display: 'none' });
				}, 300);
				break;
			case 'CreateHelp':
				$('.teclas').append(`
                <div class="flex" id="help-${event.data.id}">
                    <div class="tecla">
                        <span>${event.data.key}</span>
                    </div>
                    <div class="texto">
                        ${event.data.text || ''}
                    </div>
                </div>
                `);
				this.setTimeout(() => {
					$('#help-' + event.data.id).addClass('show');
				}, 100);
				const s_help = new Audio(
					'https://origennetwork.com/music/v7/helpnoti.ogg'
				);
				s_help.volume = 0.5;
				s_help.play();

				break;
			case 'RemoveHelp':
				$('.flex#help-' + event.data.id).removeClass('show');
				this.setTimeout(() => {
					$('.flex#help-' + event.data.id).remove();
				}, 500);
				break;
			case 'UpdateHelp':
				$('.flex#help-' + event.data.id + ' .tecla').html(event.data.key);
				$('.flex#help-' + event.data.id + ' .texto').html(event.data.text || '');
				break;
			case 'TickHelp':
				if (event.data.hide) {
					$('.teclas').fadeOut(300);
				} else {
					$('.teclas').fadeIn(300);
				}

				var movement = 0;
				if (event.data.y > -(this.window.innerHeight / 2)) {
					movement = 30;
				} else if (event.data.y < this.window.innerHeight / 2) {
					movement = -30;
				}
				parallaxIt('.teclas', movement, event.data.x, event.data.y);

				// console.log(movement);
				break;
		}
	});
});

// $("body").mousemove(function(e) {
//     parallaxIt(e, ".header", -20);
//     parallaxIt(e, ".container", -60);
//     parallaxIt(e, ".userhelp", -30);
// });

function parallaxIt(target, movement, xCoord, yCoord) {
	var $this = $('body');
	var relX = xCoord * 2 - $this.offset().left;
	var relY = yCoord * 2 - $this.offset().top; // Se establece un valor fijo en el eje Y
	// console.log(relX, relY)
	TweenMax.to(target, 1, {
		x: ((relX - $this.width() / 2) / $this.width()) * movement,
		y: ((relY - $this.height() / 2) / $this.height()) * (movement - 10)
	});
}
