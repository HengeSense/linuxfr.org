(function($) {
    $.Toolbar = function(items, text, options){
        var base = this;
        base.items = items;
        base.nb_items = items.length;

        base.init = function(){
            base.current = 0;
            base.text = text;
            base.options = $.extend({}, $.Toolbar.defaultOptions, options);
            base.storage = ('localStorage' in window && window['localStorage'] !== null) ? window['localStorage'] : {};
            base.threshold = base.storage.threshold || base.options.thresholds[0];
            base.folding();
            base.create();
        };

        base.create = function() {
            var t = '<div id="toolbar"><span id="toolbar_items">{text} : ' +
                    '  <span id="toolbar_current_item">{current}</span> / ' +
                    '  <span id="toolbar_nb_items">{nb_items}</span> ' +
                    '  <a href="#" accesskey="<" class="prev">&lt;</a> | ' +
                    '  <a href="#" accesskey=">" class="next">&gt;</a>' +
                    '</span><span id="toolbar_threshold">Seuil : ' +
                    '  <a href="#" class="change">{threshold}</a>' +
                    '</span></div>';
            $('body').append($.nano(t, base));
            $('#toolbar_items .prev').click(base.prev_item);
            $('#toolbar_items .next').click(base.next_item);
            $('#toolbar .change').click(base.change_threshold);
            /* Use the '<' and '>' to navigate in the items */
            $(document).bind('keypress', '<',       function() { return base.prev_item(); })
                       .bind('keypress', 'shift+>', function() { return base.next_item(); })
                       .bind('keypress', 'k',       function() { return base.prev_item(); })
                       .bind('keypress', 'j',       function() { return base.next_item(); });
        };

        base.next_item = function() {
            base.current += 1;
            if (base.current > base.nb_items) { base.current -= base.nb_items; }
            return base.go_to_current();
        };

        base.prev_item = function() {
            base.current -= 1;
            if (base.current <= 0) { base.current += base.nb_items; }
            return base.go_to_current();
        };

        base.go_to_current = function() {
            if (base.nb_items === 0) { return ; }
            var item = base.items[base.current - 1];
            var pos = $(item).offset().top;
            $('html,body').animate({scrollTop: pos}, 500);
            $('#toolbar_current_item').text(base.current);
            return false;
        };

        base.additional = function(alt_items, alt_text) {
            base.alt_text = alt_text;
            base.alt_items = alt_items;
            base.nb_alt_items = alt_items.length;
            base.alt_current = 0;
            var t = '<span id="toolbar_alt_items">{alt_text} : ' +
                    '  <span id="toolbar_current_alt_item">{alt_current}</span> / ' +
                    '  <span id="toolbar_nb_alt_items">{nb_alt_items}</span> ' +
                    '  <a href="#" accesskey="[" class="prev">[</a> | ' +
                    '  <a href="#" accesskey="]" class="next">]</a>' +
                    '</span>';
            $("#toolbar").prepend($.nano(t, base));
            $('#toolbar_alt_items .prev').click(base.alt_prev_item);
            $('#toolbar_alt_items .next').click(base.alt_next_item);
            $(document).bind('keypress', '[',       function() { return base.alt_prev_item(); })
                       .bind('keypress', ']',       function() { return base.alt_next_item(); })
                       .bind('keypress', 'h',       function() { return base.alt_prev_item(); })
                       .bind('keypress', 'l',       function() { return base.alt_next_item(); });
        };

        base.alt_next_item = function() {
            base.alt_current += 1;
            if (base.alt_current > base.nb_alt_items) { base.alt_current -= base.nb_alt_items; }
            return base.go_to_alt_current();
        };

        base.alt_prev_item = function() {
            base.alt_current -= 1;
            if (base.alt_current <= 0) { base.alt_current += base.nb_alt_items; }
            return base.go_to_alt_current();
        };

        base.go_to_alt_current = function() {
            if (base.nb_alt_items === 0) { return ; }
            var item = base.alt_items[base.alt_current - 1];
            var pos = $(item).parents('article').offset().top;
            $('html,body').animate({scrollTop: pos}, 500);
            $('#toolbar_current_alt_item').text(base.alt_current);
            return false;
        };

        base.change_threshold = function() {
            var ths = base.options.thresholds;
            var index = $.inArray(parseInt($(this).text(), 10), ths) + 1;
            base.storage.threshold = base.threshold = ths[index % ths.length];
            $(this).text(base.threshold);
            base.folding();
            return false;
        };

        base.folding = function() {
            if (!base.options.folding) { return ; }
            var items = $(base.options.folding);
            items.find('.folding').remove();
            items.each(function() {
                var item  = $(this);
                var score = parseInt(item.find('.score:first').text(), 10);
                var link  = item.children('h2')
                                .prepend('<a href="#" class="folding" title="Plier">[-]</a>')
                                .children('.folding');
                var fold  = function(b) {
                    if (b) {
                        item.addClass('fold');
                        link.text('[+]').attr('title', 'Déplier');
                    } else {
                        item.removeClass('fold');
                        link.text('[-]').attr('title', 'Plier');
                    }
                };
                link.click(function() {
                    fold(link.text() === '[-]');
                    return false;
                });
                fold(score < base.threshold);
            });
        };

        base.init();
    };

    $.Toolbar.defaultOptions = {
        folding: null,
        thresholds: [1, 2, 5, -42, 0]
    };

    $.fn.toolbar = function(text, options){
        return new $.Toolbar($(this), text, options);
    };
})(jQuery);
