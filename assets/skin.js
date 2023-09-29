(function() {
  var root;

  root = typeof exports !== "undefined" && exports !== null ? exports : this;

  root.CatalogController = (function() {
    function CatalogController(catalog_table) {
      this.catalog_table = catalog_table;
      this.loadCatalog();
      this.hookActions();
      this.external_base_url = 'http://www.trumpeter-china.com';
      this.brand_name = 'Trumpeter';
    }

    CatalogController.prototype.clearFilter = function() {
      $('input#keyword_contains', 'form.search').val('');
      $('select#services_contains', 'form.search').val('');
      $('select#category_equals', 'form.search').val('');
      this.applyFilter();
    };

    CatalogController.prototype.applyFilter = function() {
      var instance;
      instance = this;
      var keyword_contains = $('input#keyword_contains', 'form.search').val();
      instance.catalog_table.DataTable().search(
        keyword_contains, true, true
      ).draw();

      var category = $('select#services_contains', 'form.search').val();
      instance.catalog_table.DataTable().column(2).search(
        category, false, false
      ).draw();

      var category = $('select#category_equals', 'form.search').val();
      instance.catalog_table.DataTable().column(3).search(
        category, false, false
      ).draw();

    };

    CatalogController.prototype.hookActions = function() {
      var instance;
      instance = this;

      $('input#keyword_contains', 'form.search').on( 'keyup click', function () {
        instance.applyFilter();
      });
      $('select', 'form.search').on( 'change', function () {
        instance.applyFilter();
      });
    };

    CatalogController.prototype.loadCatalog = function() {
      var instance;
      instance = this;

      return instance.catalog_table.DataTable({
        autoWidth: false,
        ajax: {
          url: './cache/data.json',
          dataSrc: ''
        },
        columns: [
          {
            data: 'name'
          }, {
            data: 'first_flown', visible: false
          }, {
            data: 'services', visible: false
          }, {
            data: 'category', visible: false
          },
        ],
        dom: "<'row'<'col-sm-6'l><'col-sm-6'p>>" +
          "<'row'<'col-sm-12'tr>>" +
          "<'row'<'col-sm-5'i><'col-sm-7'p>>",
        order: [[0, 'asc']],
        searching: true,
        initComplete: function(settings, json) {
          instance.applyFilter();
        },
        rowCallback: function(row, data, index) {
          var cell, main_cell, description_cell;
          var url = data.url;
          var local_image_url = 'cache/images/' + data.image_local_name;
          var product_search_term = data.title.replace(' ', '+');
          var scalemates_url = 'https://www.scalemates.com/search.php?fkSECTION[]=Kits&q=' + product_search_term;
          var google_url = 'https://www.google.com/search?q=' + product_search_term;

          var info_fragment = '';
          var services_fragment = '';

          for (var i = 0; i < data.services.length; i++) {
            services_fragment = services_fragment + ' \
              <span class="label label-success">' + data.services[i] + '</span>';
          }

          info_fragment += '<dl> \
            <dt>Number built</dt> \
            <dd>' + data.number_built + '</dd> \
            </dl>';

          var name = data.name;

          if (data.title_ja) name += ' <span>(' + data.title_ja + ')</span>';

          description_cell = '<div class="row"> \
            <div class="col-sm-4 product-media"> \
              <a href="' + url + '" target="_blank"> \
                <img class="media-object" src="' + local_image_url + '" alt="' + data.title + '"> \
              </a> \
            </div> \
            <div class="col-sm-8"> \
              <h4 class="media-heading">' + name + '</h4> \
              <div class="text-muted">' + info_fragment + '</div> \
              <div> \
                ' + services_fragment + ' \
                <span class="label label-primary">' + data.category + '</span> \
              </div>  \
              <br/> \
              <div class="btn-group btn-group-sm" role="group" aria-label="..."> \
                <a href="' + url + '" target="_blank" class="btn btn-default"><i class="fa fa-link" aria-hidden="true"></i></a> \
                <a href="' + scalemates_url + '" target="_blank" type="button" class="btn btn-default">Scalemates</a> \
                <a href="' + google_url + '" target="_blank" type="button" class="btn btn-default">Google</a> \
              </div> \
            </div> \
          </div>';

          cell = $('td:eq(0)', row)
          cell.attr('data-url', url)
          cell.html(description_cell);
          return cell
        }
      });
    };

    return CatalogController;
  })();

  jQuery(function() {
    root.catalog = new root.CatalogController($('#catalog-table'));
    $('[data-action="info"]').on("click", function() {
      $('.alert').toggle();
    });
    $('[data-action="reset"]').on("click", function() {
      root.catalog.clearFilter();
    });
  });

}).call(this);
