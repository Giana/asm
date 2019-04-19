#ifndef GRAPH_H
#define GRAPH_H

#include <cstddef>
#include <iostream>
#include <iomanip>
#include <stack>
#include <queue>
#include <vector>
using namespace std;


class GRAPH{
public:
	// Constructor to use when we have an initial number of nodes & edges
	GRAPH(int nodes);
	// Constructor for stateing if a graph is directed or not
	GRAPH(bool is_directed, int nodes);
	// Set the edge going from src to dst
	void set_edge(int src, int dst, int w);
	// Print the graph's data
	void print_data(void);
	// Perform a dfs from the provided start node. Returns a vector containing
	// the search results
	vector<int> *dfs(int start);
	// perform a bfs from the provided start node. Returns a vector containing
	// the search results
	vector<int> *bfs(int start);
	// Use dijkstra's to find the shortest distance from a source node to 
	// a destination node. Returns the minimum distance between the two or
	// -1 if a path does not exist
	int dijkstra(int, int);
	// construct a MST using primm's algorithm. Returns a vector containing the
	// constructed tree
	vector<int> *primm(int);

protected:
	// Initialize the adjacency matrix
	void init();
	// Search a node in dfs algorithm
	void dfs_unit(int node, vector<int> *traversal, bool* visited);
	// A utility function to find the vertex with minimum distance value, from 
	// the set of vertices not yet included in shortest path tree 
	int minDistance(int dist[], bool sptSet[]);
	// A utility function to find the vertex with  
	// minimum key value, from the set of vertices  
	// not yet included in MST 
	int minKey(int key[], bool mstSet[]);

private:
	// Keep track of the number of nodes in the graph
	int node_count;
	// This represents the adjacency matrix
	int **data;
	bool directed;
};
#endif