var ImageList = new Class({
  initialize: function (element) { 
    this.container = element;
    this.contents = [];
    this.container.getElements('li').each(function (li) { this.contents.push(new ImageListItem(li, this)); }, this);
    this.up_items = [];
  },
  show: function (item) {
    this.up_items.push(item);
    this.hideOthers(item);
    item.show();
  },
  hideSoon: function (item) {
    item.hideSoon();
  },
  hide: function (item) {
    item.hide();
  },
  hideOthers: function (exception) {
    this.up_items.each(function (item) {
      if (item != exception) this.hideSoon(item);
    }, this);
  }
});

var ImageListItem = new Class({
  initialize: function (element, list) { 
    this.list = list;
    this.container = element;
    this.container.addEvent('mouseover', this.list.show.bind(this.list, this));
    this.preview = new ImagePreview(this.container.getElement('img'));
  },
  show: function () {
    this.preview.preview();
  },
  hide: function (argument) {
    this.preview.hide();
  },
  hideSoon: function (argument) {
    this.preview.hideSoon();
  },
  lazy_load_preview: function () {
    if (!this.preview) this.preview = new ImagePreview(this.container.getElement('img'));
    return this.preview;
  }
});

var ImagePreview = new Class({
  initialize: function (img) {
    this.img = img;
    this.img.fade(0.4);

    this.url = img.get('src').replace('_small', '_large');
    this.shower = new Asset.image(this.url, {title: this.img.get('title'), onload: this.makeReady.bind(this)});

    this.at = img.getCoordinates();
    this.hiding = {
      'top' : this.at.top - 4,
      'left' : this.at.left - 4,
      'width' : this.at.width,
      'height' : this.at.height,
      'opacity' : 0
    };
    
    this.previewing = {};
    this.showing = {};
    
    this.upfx = this.downfx = null;
    this.delay = null;
    this.is_ready = false;

  },
  makeReady: function () {
    var w = this.shower.get('width');
    var h = this.shower.get('height');
    this.shower.addClass('preview');
    this.shower.inject(document.body);
    this.shower.setStyles(this.hiding);
    this.shower.hide();
    this.previewing = {
      'top' : Math.floor((this.at.top + this.at.height/2) - (h/2) - 4),
      'left' : Math.floor((this.at.left + this.at.width/2) - (w/2) - 4),
      'width' : w,
      'height' : h,
      'opacity' : 1
    };
    this.img.fade('in');
    this.is_ready = true;
  },
  preview: function () {
    if (this.is_ready) {
      this.cancelDown();
      this.shower.bringForward();
      this.shower.addEvent('mouseout', this.hideSoon.bind(this));
      this.shower.show();
      this.upper().start(this.previewing);
    }
  },
  hide: function () {
    this.cancelUp();
    this.downer().start(this.hiding);
    this.shower.addEvent('mouseover', this.preview.bind(this));
  },
  hideSoon: function () {
    this.delay = this.hide.bind(this).delay(200);
  },
  reallyHide: function () {
    this.shower.hide();
  },
  upper: function () {
    if (!this.upfx) this.upfx = new Fx.Morph(this.shower, {duration: 'short', transition: Fx.Transitions.Quad.easeOut});
    return this.upfx;
  },
  cancelUp: function () {
    if (this.upfx) this.upfx.cancel();
  },
  downer: function () {
    if (!this.downfx) this.downfx = new Fx.Morph(this.shower, {duration: 'long', onComplete: this.reallyHide.bind(this)});
    return this.downfx;
  },
  cancelDown: function () {
    if (this.delay) $clear(this.delay);
    if (this.downfx) this.downfx.cancel();
  }
});

var top_z = null;
var topZ = function () {
  if (top_z) return top_z;
  $$('*').each(function (element) {
    z = parseInt(element.getStyle('z-index'), 10);
    if (z > top_z) top_z = z;
  });
  return top_z;
};

Element.implement({
  front: function () {
    top_z = topZ() + 1;
    this.setStyle('z-index', top_z);
  }
});



activations.push(function (scope) {
  scope.getElements('ul.imagelist').each( function (ul) { new ImageList(ul); }); 
});
