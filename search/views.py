from django.conf import settings
from django.shortcuts import render_to_response
from django.template import RequestContext
from utils.search.solr import Solr, SolrQuery, SolrResponseInterpreter, \
    SolrResponseInterpreterPaginator, SolrException
import logging
import forms

logger = logging.getLogger("search")

def search_prepare_sort(sort, options):
    """ for ordering by rating order by rating, then by number of ratings """
    if sort in [x[1] for x in options]:
        if sort == "avg_rating desc":
            sort = [sort, "num_ratings desc"]
        elif  sort == "avg_rating asc":
            sort = [sort, "num_ratings asc"]
        else:
            sort = [sort]
    else:
        sort = ["num_downloads desc"]
    return sort

def search_prepare_query(search_query, filter_query, sort, current_page, sounds_per_page):
    query = SolrQuery()
    query.set_dismax_query(search_query,
                           query_fields=[("id", 4),
                                         ("tag",3),
                                         ("description",3),
                                         ("username",2),
                                         ("pack_tokenized",2),
                                         ("original_filename",2)])
    query.set_query_options(start=(current_page - 1) * sounds_per_page, rows=sounds_per_page, field_list=["id"], filter_query=filter_query, sort=sort)
    query.add_facet_fields("samplerate", "pack", "username", "tag", "bitrate", "bitdepth", "type", "channels")
    query.set_facet_options_default(limit=5, sort=True, mincount=1, count_missing=False)
    query.set_facet_options("tag", limit=30)
    query.set_facet_options("username", limit=30)
    query.set_facet_options("pack", limit=10)
    return query

def search(request):
    search_query = request.GET.get("q", "")
    filter_query = request.GET.get("f", "")
    current_page = int(request.GET.get("page", 1))
    sort = request.GET.get("s", forms.SEARCH_DEFAULT_SORT)
    sort_options = forms.SEARCH_SORT_OPTIONS_WEB

    # Allow to return ALL sounds when search has no q parameter
    #if search_query.strip() != "": 
    sort = search_prepare_sort(sort, forms.SEARCH_SORT_OPTIONS_WEB)

    solr = Solr(settings.SOLR_URL)

    query = search_prepare_query(search_query, filter_query, sort, current_page, settings.SOUNDS_PER_PAGE)

    try:
        results = SolrResponseInterpreter(solr.select(unicode(query)))
        paginator = SolrResponseInterpreterPaginator(results, settings.SOUNDS_PER_PAGE)
        num_results = paginator.count
        page = paginator.page(current_page)
        error = False
    except SolrException, e:
        logger.warning("search error: query: %s error %s" % (query, e))
        error = True
        error_text = 'There was an error while searching, is your query correct?'
    except Exception, e:
        logger.error("Could probably not connect to Solr - %s" % e)
        error = True
        error_text = 'The search server could not be reached, please try again later.'
    #else:
    #    results = []

    if request.GET.get("ajax", "") != "1":
        return render_to_response('search/search.html', locals(), context_instance=RequestContext(request))
    else:
        return render_to_response('search/search_ajax.html', locals(), context_instance = RequestContext(request))
    
    
def get_pack_tags(pack_obj):
    query = SolrQuery()
    query.set_dismax_query('')
    #filter_query = 'username:\"%s\" pack:\"%s\"' % (pack_obj.user.username, pack_obj.name)
    filter_query = 'pack:\"%s\"' % (pack_obj.name,)
    query.set_query_options(field_list=["id"], filter_query=filter_query)
    query.add_facet_fields("tag")
    query.set_facet_options("tag", limit=20, mincount=1)
    solr = Solr(settings.SOLR_URL)
    
    try:
        results = SolrResponseInterpreter(solr.select(unicode(query)))
    except SolrException, e:
        #logger.warning("search error: query: %s error %s" % (query, e))
        #error = True
        #error_text = 'There was an error while searching, is your query correct?'
        return False
    except Exception, e:
        #logger.error("Could probably not connect to Solr - %s" % e)
        #error = True
        #error_text = 'The search server could not be reached, please try again later.' 
        return False
    
    return results.facets


