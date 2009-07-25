var nowt = "";

window.addEvent('domready', function() {
  $$('div.gallery').each( function (element) { new Gallery(element); }); 
  $$('div.minigallery').each( function (element) { new Minigallery(element); }); 
});

var blockEvent = function (e) {
  if (e) {
    var event = new Event(e).stop();
    event.preventDefault();
    if (event.target) event.target.blur();
    return event;
  }
};

var Gallery = new Class({
  initialize: function (element) { 
    this.container = element;   
    this.shower = this.container.getElement('.gallery_shower');
    this.captioner = this.container.getElement('.gallery_caption');
    this.wrapper = this.container.getElement('.gallery_wrapper');
    this.footer = this.container.getElement('.gallery_foot');
    this.main_link = new Element('a').inject(this.shower);
    this.showing = new Element('img').inject(this.main_link);
    this.revert_message = this.captioner.get('text');
    
    this.scroller = new Fx.Scroll(this.wrapper, {transition: Fx.Transitions.Cubic.easeOut, duration: 'long', onComplete: this.showPageLinks.bind(this)});
    this.transitionOut = new Fx.Tween(this.showing, {property: 'opacity', onComplete: this.preloadIncomingItem.bind(this)});
    this.transitionIn = new Fx.Tween(this.showing, {property: 'opacity', onComplete: this.setCaptionAndLinks.bind(this)});
    
    this.pages = [];
    this.container.getElements('ul.gallery_page').each(function (element) { this.pages.push(new GalleryPage(element, this)); }, this);

    if (this.pages.length > 0) {
      this.first_page = this.pages[0];
      this.last_page = this.pages[this.pages.length - 1];
    
      this.current_page = this.first_page;
      this.current_item = null;
      this.incoming_item = null;

      this.page_lefter = this.container.getElement('a.gallery_left');
      this.page_righter = this.container.getElement('a.gallery_right');

      this.links_holder = new Element('div', {'class': 'gallery_links'}).inject(this.shower);
      this.image_lefter = new Element('a', {'class': 'item_left', 'href': '#', 'title': 'previous'}).inject(this.links_holder);
      this.downloader = new Element('a', {'class': 'item_download', 'href': '#', 'target': '_blank', 'title': 'download'}).inject(this.links_holder);
      this.image_righter = new Element('a', {'class': 'item_right', 'href': '#', 'title': 'next'}).inject(this.links_holder);

      this.image_lefter.onclick = this.showPreviousItem.bindWithEvent(this);
      this.image_righter.onclick = this.showNextItem.bindWithEvent(this);
      this.page_lefter.onclick = this.moveLeft.bindWithEvent(this);
      this.page_righter.onclick = this.moveRight.bindWithEvent(this);

      this.showPageLinks();
      this.showPageNumber();
      this.preloader = null;
      this.current_page.first_item.showMe();

    } else {
      this.footer.set('text', '');
    }
  },
  pageBefore: function (page) {
    if (!page) page = this.current_page;
    if (page == this.first_page) return this.last_page; 
    if (page && this.pages.contains(page)) return this.pages[this.pages.indexOf(page)-1];
    return this.last_page;
  },
  pageAfter: function (page) {
    if (!page) page = this.current_page;
    if (page == this.last_page) return this.first_page;
    if (page && this.pages.contains(page)) return this.pages[this.pages.indexOf(page)+1];
    return this.first_page;
  },
  moveLeft: function (e) {
    blockEvent(e);
  	this.showPage(this.pageBefore());
  },
  moveRight: function (e) {
    blockEvent(e);
  	this.showPage(this.pageAfter());
  },
  showPage: function (page) {
    if (page != this.current_page) {
    	this.scroller.toElement(page.container);
      this.current_page = page;
      this.showPageNumber();
    }
  },
  showPageLinks: function () {
    if (this.pages.length == 1) {
      this.page_lefter.setStyle('visibility', 'hidden');
      this.page_righter.setStyle('visibility', 'hidden');
    } else {
      if (this.current_page == this.last_page) this.page_righter.addClass('right_end');
      else this.page_righter.removeClass('right_end');
      if (this.current_page == this.first_page) this.page_lefter.addClass('left_end');
      else this.page_lefter.removeClass('left_end');
    }
  },
  showPageNumber: function () {
    this.footer.set('text', 'Page ' + this.current_page.page_number + ' of ' + this.pages.length);
  },
  showPreviousItem: function (e) {
    blockEvent(e);
    this.current_item.previousItem().showMe();
  },
  showNextItem: function (e) {
    blockEvent(e);
    this.current_item.nextItem().showMe();
  },
  showItem: function (item) {     // this should not be called directly. call item.showMe() to hit page and item triggers properly.
    if (item != this.current_item) {
      this.incoming_item = item;
      this.hideItem();            // triggers a sequence of preloads and transitions that eventually fades up the called image
    }
  },
  hideItem: function () {
    if (this.current_item) this.current_item.unHighlightMe();
    this.say(nowt);
    this.links_holder.hide();
    this.transitionOut.start(0);  // -> preloadIncomingItem
  },
  preloadIncomingItem: function () {
    var fadeup = this.finishShowItem.bind(this);
    this.preloader = new Asset.image(this.incoming_item.preview_url, {onload : fadeup});  // -> finishShowItem
  },
  finishShowItem: function () {
    this.showing.set('src', this.preloader.get('src'));
    this.downloader.set('href', this.incoming_item.download_url);
    this.main_link.set('href', this.incoming_item.download_url);
    this.current_item = this.incoming_item;
    this.incoming_item = null;
    this.current_item.highlightMe();
    this.transitionIn.start(1);  // -> setCaptionAndLinks
  },
  setCaptionAndLinks: function () {
    this.say(this.current_item.caption);
    var links_pos = {
      'left': this.showing.getLeft() - this.shower.getLeft(), 
      'width': this.showing.getWidth(), 
      'height': this.showing.getHeight()
    };
    this.links_holder.setStyles(links_pos);
    this.links_holder.show();
    // this.links_holder.setStyle('background-color', '#d1005d');
  },
  say: function (message) {
    this.revert_message = this.captioner.get('html');
    this.captioner.set('html', message);
  },
  unsay: function (message) {
    this.captioner.set('html', this.revert_message);
  }
});

var GalleryPage = new Class({
  initialize: function (element, gallery) {    
    this.container = element;
    this.id = element.id;
    this.gallery = gallery;
    this.page_number = this.gallery.pages.length + 1;
    this.items = [];
    this.container.getElements('li.gallery_item').each(function (element) { this.items.push(new GalleryItem(element, this)); }, this);
    this.first_item = this.items[0];
    this.last_item = this.items[this.items.length-1];
    this.current_item = null;
  },
  showMe: function (e) {
    blockEvent(e);
    this.gallery.showPage(this);
  },
  showItem: function (item) {
    this.showMe();
    this.current_item = item;
    this.gallery.showItem(item);
  },
  previousPage: function () {
    return this.gallery.pageBefore(this);
  },
  nextPage: function () {
    return this.gallery.pageAfter(this);
  },
  itemBefore: function (item) {
    if (!item) item = this.current_item;
    if (item == this.first_item) return this.previousPage().last_item;
    if (item && this.items.contains(item)) return this.items[this.items.indexOf(item)-1];
    return this.last_item;
  },
  itemAfter: function (item) {
    if (!item) item = this.current_item;
    if (item == this.last_item) return this.nextPage().first_item;
    if (item && this.items.contains(item)) return this.items[this.items.indexOf(item)+1];
    return this.first_item;
  }
});

var GalleryItem = new Class({
  initialize: function (element, gallerypage) {    
    this.icon = element.getElement('img');
    this.id = element.get('id');
    this.clicker = element.getElement('a.gallery_preview');
    this.downloader = element.getElement('a.gallery_download');
    this.preview_url = this.clicker.get('href');
    this.download_url = this.downloader.get('href');
    this.caption = this.downloader.get('html');
    this.page = gallerypage;
    this.gallery = gallerypage.gallery;
    this.clicker.onclick = this.showMe.bindWithEvent(this);
    this.borderFX = new Fx.Tween(this.icon, {property: 'border-color'});
  },
  showMe: function (e) {
    blockEvent(e);
    this.page.showItem(this);
  },
  showCaption: function (e) {
    blockEvent(e);
    this.gallery.say(this.caption);
  },
  hideCaption: function (e) {
    blockEvent(e);
    this.gallery.unsay(this.caption);
  },
  previousItem: function () {
    return this.page.itemBefore(this);
  },
  nextItem: function () {
    return this.page.itemAfter(this);
  },
  highlightMe: function () {
    this.borderFX.start('#d1005d');
  },
  unHighlightMe: function () {
    this.borderFX.start('#ffffff');
  }
});

var Minigallery = new Class({
  initialize: function (element) { 
    this.container = element;   
    this.showing = this.container.getElement('img');
    this.caption = this.container.getElement('p.caption');
    this.items = [];
    this.container.getElements('li.thumbnail').each(function (element) { this.items.push(new MinigalleryItem(element, this)); }, this);
    this.current_item = this.items[0];
    this.incoming_item = null;
    this.preloader = null;
    this.showing.set('tween', {duration: 'short', onComplete: this.loadIncomingItem.bind(this)});
    this.current_item.showMe();
  },
  showItem: function (item) {
    this.incoming_item = item;
    this.fadeOut();
  },
  fadeOut: function () {
    this.current_item.hideMe();
    this.showing.fade('out');  // -> loadIncomingItem
    this.caption.fade('out');
  },
  loadIncomingItem: function (argument) {
    if (this.incoming_item) {
      var fadein = this.fadeIn.bind(this);
      this.preloader = new Asset.image(this.incoming_item.bigger, {onload : fadein});  // -> fadeIn
    }
  },
  fadeIn: function () {
    this.showing.set('src', this.preloader.get('src'));
    this.current_item = this.incoming_item;
    this.incoming_item = null;
    this.caption.set('text', this.current_item.caption);
    this.showing.fade('in');
    this.caption.fade('in');
  }
});

var MinigalleryItem = new Class({
  initialize: function (element, gallery) {    
    this.container = element;
    this.gallery = gallery;
    this.icon = element.getElement('img');
    this.clicker = element.getElement('a');
    this.caption = this.clicker.get('title');
    this.bigger = this.clicker.get('href');
    this.clicker.onclick = this.showMe.bindWithEvent(this);
  },
  showMe: function (e) {
    blockEvent(e);
    this.gallery.showItem(this);
    this.clicker.addClass('up');
  },
  hideMe: function () {
    this.clicker.removeClass('up');
  }
});
