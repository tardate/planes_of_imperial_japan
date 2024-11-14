(function() {
  var root;

  root = typeof exports !== "undefined" && exports !== null ? exports : this;

  root.CatalogController = (function() {
    function CatalogController(catalog_table) {
      this.catalog_table = catalog_table;
      this.loadCatalog();
      this.hookActions();
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

      var service = $('select#services_contains', 'form.search').val();
      instance.catalog_table.DataTable().column(2).search(
        service, false, false
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
            data: 'categories', visible: false
          },{
            data: 'description', visible: false
          },
        ],
        dom: "<'row'<'col-sm-5'l><'col-sm-7'p>>" +
          "<'row'<'col-sm-12'tr>>" +
          "<'row'<'col-sm-5'i><'col-sm-7'p>>",
        order: [[0, 'asc']],
        searching: true,
        initComplete: function(settings, json) {
          instance.applyFilter();
        },
        rowCallback: function(row, data, index) {
          var url = data.url;
          var local_image_url = 'cache/images/' + (data.image_local_name || 'undefined.jpg');
          var product_search_term = data.title.replace(' ', '+');
          var scalemates_url = 'https://www.scalemates.com/search.php?fkSECTION[]=Kits&q=' + product_search_term;
          var google_url = 'https://www.google.com/search?q=' + product_search_term;

          var services_styles = '';
          for (var i = 0; i < data.services.length; i++) {
            services_styles += ' service-' + data.services[i].toLowerCase();
          }

          var allied_code_fragment = '';
          if (data.allied_code) {
            allied_code_fragment += '<li class="list-group-item"> \
                <span class="badge">' + data.allied_code + '</span> \
                Allied Code \
              </li>'
          }

          var categories_fragment = '';
          for (var i = 0; i < data.categories.length; i++) {
            categories_fragment += '<span class="label label-primary">' + data.categories[i] + '</span> ';
          }
          var info_fragment = '<ul class="list-group"> \
              <li class="list-group-item"> \
                <span class="display-ija" style="display: none;"> \
                  <img src="assets/flag_ija.png" alt="IJA"/> \
                  <span class="service-name">IJA</span> \
                </span> \
                <span class="display-ijn" style="display: none;"> \
                  <img src="assets/flag_ijn.png" alt="IJN"/> \
                  <span class="service-name">IJN</span> \
                </span> \
              </li> \
              <li class="list-group-item"> ' + categories_fragment + ' </li> \
              ' + allied_code_fragment + ' \
              <li class="list-group-item"> \
                <span class="badge">' + data.first_flown + '</span> \
                First Flown \
              </li> \
              <li class="list-group-item"> \
                <span class="badge">' + data.number_built + '</span> \
                Number Built \
              </li> \
            </ul>';

          var name = data.name;
          if (data.title_ja) name += ' <span>(' + data.title_ja + ')</span>';

          var main_description = '<p class="description">' + data.description + '</p> \
            <div class="btn-group btn-group-sm" role="group"> \
              <div class="btn"><strong>More info:</strong></div> \
              <a href="' + url + '" target="_blank" class="btn btn-default"><i class="fa fa-wikipedia-w" aria-hidden="true"></i></a> \
              <a href="' + google_url + '" target="_blank" type="button" class="btn btn-default">Google</a> \
              <a href="' + scalemates_url + '" target="_blank" type="button" class="btn btn-default">Scalemates</a> \
            </div> \
            <br/><br/>';

          var description_cell = '<div class="media' + services_styles + '" data-uuid="' + data.uuid + '"> \
            <div class="media-left plane-media hidden-xs"> \
              <a href="' + url + '" target="_blank"> \
                <img class="media-object" src="' + local_image_url + '" alt="' + data.title + '"/> \
              </a> \
            </div> \
            <div class="media-body"> \
              <row> \
                <div class="col-md-8"> \
                  <h4 class="media-heading">' + name + '</h4> \
                  <div class="plane-media visible-xs-block"> \
                    <a href="' + url + '" target="_blank"> \
                      <img class="media-object" src="' + local_image_url + '" alt="' + data.title + '"/> \
                    </a> \
                  </div> \
                  ' + main_description + ' \
                </div> \
                <div class="col-md-4"> \
                  ' + info_fragment + ' \
                </div> \
              </row> \
            </div> \
          </div>';

          var cell = $('td:eq(0)', row)
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
    $('[data-action="reset"]').on("click", function() {
      root.catalog.clearFilter();
    });
  });

}).call(this);
