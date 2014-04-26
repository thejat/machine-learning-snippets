import graphlab
sf = graphlab.SFrame(data='http://graphlab.com/files/datasets/freebase_performances.csv')
print sf
g = graphlab.Graph()
g = g.add_edges(sf, 'actor_name', 'film_name')
pr = graphlab.pagerank.create(g)
pr.get('pagerank').topk(column_name='pagerank')
