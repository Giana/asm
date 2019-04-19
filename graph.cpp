#include "graph.h"
#include <list>
//#include "pq.hpp"


GRAPH::GRAPH(int nodes) : directed(false), node_count(nodes), data(0)
{
	init();
}

void GRAPH::init()
{
	data = new int*[node_count];

	if (data)
	{

		for (int i = 0; i < node_count; i ++)
		{
			data[i] = (int*)malloc(sizeof(int) * node_count);

			if (data[i])
			{
				memset(data[i], 0, sizeof(int) * node_count);
			}
		}
	}
}

GRAPH::GRAPH(bool is_directed, int nodes) : directed(is_directed), node_count(nodes), data(0)
{
	init();
}

void GRAPH::set_edge(int source, int destination, int w)
{
	int src = source - 1;
	int dst = destination - 1;

	if (src >= 0 && src < node_count && dst >= 0 && dst < node_count)
	{
		data[src][dst] = w;

		if (!directed) data[dst][src] = w;
	}
}

void GRAPH::print_data()
{

	for (int i = 0; i < node_count; i ++)
	{

		for (int j = 0; j < node_count; j ++)
		{

			if (data[i][j]) printf("%d, %d, %d", i + 1, j + 1, data[i][j]);
		}
	}
}

vector<int> *GRAPH::dfs(int start)
{
	bool* visited = new bool[node_count];
	vector<int> *traversal = new vector<int>();

	if (start < 1 || start > node_count || !visited) return traversal;

    // Mark all the vertices as not visited 
    for (int i = 0; i < node_count; i++) visited[i] = false; 

    // Call the recursive helper function to print DFS traversal 
    // starting from all vertices one by one 
    for (int j = 0; j < node_count; j++) 
	{
		int index = (start - 1 + j) % node_count;

        if (!visited[index]) dfs_unit(index, traversal, visited);
	}

	return traversal;
}

void GRAPH::dfs_unit(int node, vector<int> *traversal, bool* visited)
{
	visited[node] = true;
	traversal->push_back(node + 1);

	for (int i = 0; i < node_count; i ++)
	{

		if (data[node][i] && !visited[i]) dfs_unit(i, traversal, visited);
	}
}

vector<int> *GRAPH::bfs(int start)
{
   // Create a queue for BFS 
    list<int> queue;
	vector<int> *traversal = new vector<int>();

	// Mark all the vertices as not visited 
	bool* visited = new bool[node_count];

	for (int i = 0; i < node_count; i ++) visited[i] = false;
  
    // Mark the current node as visited and enqueue it 
    visited[start - 1] = true; 
    queue.push_back(start - 1); 
    
    while (!queue.empty()) 
    { 
        // Dequeue a vertex from queue and print it 
        int s = queue.front(); 
        traversal->push_back(s + 1); 
        queue.pop_front(); 
  
        // Get all adjacent vertices of the dequeued 
        // vertex s
		// If a adjacent has not been visited,  
        // then mark it visited and enqueue it 
		for (int j = 0; j < node_count; j ++)
		{

			if (data[s][j] && !visited[j]) 
			{
				visited[j] = true;
				queue.push_back(j); 
			}
		} 
    } 

	return traversal;
}

int GRAPH::dijkstra(int src, int dst)
{
	// The output array
	// dist[i] will hold the shortest distance from src to i 
    int* dist = new int[node_count];
	// sptSet[i] will be true if vertex i is included in
	// shortest path tree or shortest distance from src to i is finalized 
    bool* sptSet = new bool[node_count]; 
    int dis_min = -1;

     // Initialize all distances as infinite and sptSet[] as false 
     for (int i = 0; i < node_count; i++) 
	 {
        dist[i] = INT_MAX;
		sptSet[i] = false; 
	 }

     // Distance of source vertex from itself is always 0 
     dist[src - 1] = 0; 
   
     // Find shortest path for all vertices 
     for (int count = 0; count < node_count - 1; count++) 
     { 
       // Pick the minimum distance vertex from the set of vertices not 
       // yet processed
	   // u is always equal to src in the first iteration 
       int u = minDistance(dist, sptSet); 
       // Mark the picked vertex as processed 
       sptSet[u] = true; 
   
       // Update dist value of the adjacent vertices of the picked vertex
		for (int v = 0; v < node_count; v++) 
		{
			// Update dist[v] only if is not in sptSet, there is an edge from  
			// u to v, and total weight of path from src to  v through u is  
			// smaller than current value of dist[v] 
			if (!sptSet[v] && data[u][v] && dist[u] != INT_MAX && dist[u] + data[u][v] < dist[v]) 
			{
            	dist[v] = dist[u] + data[u][v]; 
			}
		}
     } 
	 dis_min = dist[dst - 1];
	 delete []dist;
	 delete []sptSet;
	 return dis_min;
}

int GRAPH::minDistance(int dist[], bool sptSet[]) 
{ 
	// Initialize min value 
	int min = INT_MAX, min_index; 
   
	for (int v = 0; v < node_count; v++)
	{ 

		if (sptSet[v] == false && dist[v] <= min) 
		{
			min = dist[v], min_index = v; 
		}
	}
	return min_index; 
}

int GRAPH::minKey(int key[], bool mstSet[]) 
{ 
	// Initialize min value 
	int min = INT_MAX;
	int min_index = 0; 

	for (int v = 0; v < node_count; v++) 
	{

		if (mstSet[v] == false && key[v] < min) 
		{
			min = key[v], min_index = v; 
		}
	}
	return min_index; 
}

vector<int> *GRAPH::primm(int src)
{
    // Array to store constructed MST 
    vector<int>* mst = new vector<int>();  
	mst->assign(node_count, 0);
    // Key values used to pick minimum weight edge in cut 
    int* key = new int[node_count];  
    // To represent set of vertices not yet included in MST 
    bool* mstSet = new bool[node_count];  
  
    // Initialize all keys as infinite 
    for (int i = 0; i < node_count; i++) 
	{
        key[i] = INT_MAX;
		mstSet[i] = false; 
	}
	
    // Always include first 1st vertex in MST
    // Make key 0 so that this vertex is picked as first vertex
    key[src - 1] = 0;  
    (*mst)[src - 1] = -1; // First node is always root of MST  
  
    // The MST will have V vertices 
    for (int count = 0; count < node_count - 1; count++) 
    { 
        // Pick the minimum key vertex from the  
        // set of vertices not yet included in MST 
        int u = minKey(key, mstSet); 
        // Add the picked vertex to the MST Set 
        mstSet[u] = true; 

        // Update key value and parent index of  
        // the adjacent vertices of the picked vertex  
        // Consider only those vertices which are not  
        // yet included in MST 
        for (int v = 0; v < node_count; v++) 
		{

			// graph[u][v] is non zero only for adjacent vertices of m 
			// mstSet[v] is false for vertices not yet included in MST 
			// Update the key only if graph[u][v] is smaller than key[v] 
			if (data[u][v] && mstSet[v] == false && data[u][v] < key[v]) 
			{
				(*mst)[v + 1] = u + 1, key[v] = data[u][v]; 
			}
		}
    } 
	return mst;
}