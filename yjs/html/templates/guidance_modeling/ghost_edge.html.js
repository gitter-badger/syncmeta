define('text!templates/guidance_modeling/ghost_edge.html',[],function () { return '<!-- <button class=\'bs-btn bs-btn-default bs-btn-s\' style="z-index: 30000; opacity:0.4;">\n\t<i class=\'fa fa-plus\' style=\'margin-right:5px;\'></i><%= label %>\n</button> -->\n<!-- Split button -->\n<div class="bs-btn-group" style="z-index: 30000; opacity:0.4;">\n  <button type="bs-button" class="bs-btn bs-btn-default create-edge-button"><i class=\'fa fa-plus\' style=\'margin-right:5px;\'></i><span class="label"></span></button>\n  <button type="bs-button" class="bs-btn bs-btn-default bs-dropdown-toggle" data-toggle="dropdown" aria-haspopup="true" aria-expanded="false" style="min-height:34px;">\n    <span class="bs-caret"></span>\n  </button>\n  <ul class="bs-dropdown-menu edge-list">\n  </ul>\n</div>';});