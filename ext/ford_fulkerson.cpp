#include "./config.h"
#include <bits/stdc++.h>
using namespace std;

#ifndef NO_RUBY_EXT
#include <rice/rice.hpp>
#include <rice/stl.hpp>
using namespace Rice;
#endif

template <class T>
struct Edge {
  int rev, from, to;  // rev:逆向きの辺の番号
  T cap, original_cap;
  Edge(int r, int f, int t, T c) : rev(r), from(f), to(t), cap(c), original_cap(c) {}
};

template <class T>
struct Graph {
  vector<vector<Edge<T>>> G;
  Graph(int n = 0) : G(n) {}
  vector<Edge<T>>& operator[](int i) { return G[i]; }
  const size_t size() const { return G.size(); }
  Edge<T>& redge(Edge<T> e) {  // 逆向きの辺を返す
    return G[e.to][e.rev];   // 自己ループはないと仮定（あれば G[e.to][e.rev + 1] とする必要がある）
  }
  void add_edge(int from, int to, T cap) {  // 有向辺を加える
    G[from].push_back(Edge<T>((int)G[to].size(), from, to, cap));
    G[to].push_back(Edge<T>((int)G[from].size() - 1, to, from, 0));
  }
};

/* FordFulkerson: Ford-Fulkersonのアルゴリズムで最大流を求める構造体
   max_flow(G,s,t) ：グラフGの最大流が求まる
   副作用：G は最大流の残余ネットワークになる
   計算量: O(|f*||E|) (f*:最大流) 
 */
template <class T>
struct FordFulkerson {
  const T INF = 1e9;
  vector<int> used;
  vector<int> last_used;

  FordFulkerson(){};
  T dfs(Graph<T>& G, int v, int t, T f) {  // 増加可能経路を見つけて増加分のフローを返す
    if (v == t) return f;
    used[v] = 1;
    for (auto& e : G[v]) {
      if (used[e.to] == 0 && e.cap > 0) {
        T d = dfs(G, e.to, t, min(f, e.cap));
        if (d > 0) {
          e.cap -= d;
          G.redge(e).cap += d;
          return d;
        }
      }
    }
    return 0;
  }
  T max_flow(Graph<T>& G, int s, int t) {
    T flow = 0;
    while (true) {
      last_used.clear();
      for (int i = 0; i < used.size(); i++) {
        last_used.push_back(used[i]);
      }
      used.assign(G.size(), 0);
      T f = dfs(G, s, t, INF);  // f が増加分のフロー
      if (f == 0) {
        return flow;
      } else {
        flow += f;
      }
    }
    return 0;
  }
};

#ifdef NO_RUBY_EXT
int main() {
  int X, Y, E;
  cin >> X >> Y >> E;
  Graph<int> G(X + Y + 2);
  for (int i = 0; i < X; i++) {  // ソース(0)から X(1~X) への辺
    G.add_edge(0, i + 1, 1);
  }
  for (int i = 0; i < E; i++) {  // X(1~X) から Y(X+1~X+Y) への辺
    int x, y;
    cin >> x >> y;
    G.add_edge(x + 1, y + X + 1, 1);
  }
  for (int i = 0; i < Y; i++) {  // Y(X+1~X+Y) からシンク(X+Y+1)への辺
    G.add_edge(i + X + 1, X + Y + 1, 1);
  }

  FordFulkerson<int> ff;
  cout << ff.max_flow(G, 0, X + Y + 1) << endl;
}
#else

extern "C" {
  
  void Init_ford_fulkerson() {
    Data_Type<Graph<int>> rb_cGraph =
      define_class<Graph<int>>("Graph")
      .define_constructor(Constructor<Graph<int>, int>(), (Arg("n")))
      .define_method("add_edge", &Graph<int>::add_edge);

    Data_Type<FordFulkerson<int>> rb_cFordFulkerson =
      define_class<FordFulkerson<int>>("FordFulkerson")
      .define_constructor(Constructor<FordFulkerson<int>>())
      .define_method("max_flow", &FordFulkerson<int>::max_flow)
      .define_attr("used", &FordFulkerson<int>::last_used, Rice::AttrAccess::Read);
  };
}
#endif
