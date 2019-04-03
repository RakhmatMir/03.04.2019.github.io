$(document).ready(function(){
	// owlCarousel
	$(".reviews__inner--slayd").owlCarousel({
		loop:true,
		dots: false,
		nav:true,
		autoplay: false,
		responsiveClass:true,
		responsive:{
			0:{
				items:1,
			},
			575:{
				items:1,
			},
			767:{
				items:1,
			},
			992:{
				items:1,
			},
			1280:{
				items:1,
			}
		}
	});
	var mdl = window.matchMedia('all and (max-width: 480px)');
	if(mdl.matches){
		$(".Rih--movue-slayd").owlCarousel({
			loop:true,
			dots: false,
			nav:true,
			autoplay: false,
			responsiveClass:true,
			responsive:{
				0:{
					items:1,
				},
				767:{
					items:1,
					nav:true,
				},
				768:{
					items:0,
				},
			}
		});
	}else {
		$(".Rih--movue-slayd").removeClass("owl-carousel owl-theme")
	}
	var lgl = window.matchMedia('all and (max-width: 991px)');
	if(lgl.matches){
		$(".weHave__inner--body").owlCarousel({
			loop:true,
			dots: false,
			nav:true,
			autoplay: false,
			responsiveClass:true,
			responsive:{
				0:{
					items:1,
					nav: false,
				},
				480:{
					items:1,
				},
				767:{
					items:2,
				},
				991:{
					items:2,
				},
				992:{
					items:0
				}
			}
		});
	}else {
		$(".weHave__inner--body").removeClass("owl-carousel owl-theme")
	}
	if(lgl.matches){
		$(".usadba__inner--body").owlCarousel({
			loop:true,
			dots: false,
			nav:true,
			autoplay: false,
			responsiveClass:true,
			responsive:{
				0:{
					items:1,
					nav:false
				},
				480:{
					items:1,
				},
				767:{
					items:1,
				},
				991:{
					items:1,
				},
				992:{
					items:0
				}
			}
		});
	}else {
		$(".usadba__inner--body").removeClass("owl-carousel owl-theme")
	}
	// end owlCarousel
	// adaptive menu header
	$(".head-menu").on("click", function(e) {
		e.preventDefault();
		$(".Hih-left").addClass("Hih-left-open");
	});
	$(".Hih-left-bg,.Hih-left-clouse").on("click", function() {
		$(".Hih-left").removeClass("Hih-left-open");
	});
	// end adaptive menu header
	// about menu
	$(".about-menu").on("click", function(e) {
		e.preventDefault();
		$(this).toggleClass("color")
		$(".about-menu-inside").stop().slideToggle();
		$(".about-menu img").toggleClass("span");
		$(".black").toggle();
		$(".white").toggle();
	});
	// about menu
});
$('.up').click(function(){
	$('html, body').animate({scrollTop:0}, 1200);
	return true;
});
$('a[href="#"]').click(function(e){
	e.preventDefault();
});