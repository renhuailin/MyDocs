Istio
---------------

Pilot是智能路由

Each Envoy instance maintains [load balancing information](https://istio.io/docs/concepts/traffic-management/load-balancing.html) based on the information it gets from Pilot and periodic health-checks of other instances in its load-balancing pool, allowing it to intelligently distribute traffic between destination instances while following its specified routing rules.

Envoy包含了负载均衡的信息，这些信息依据从Pilot里获取的信息和同时周期性地检查池里实例的健康状态而生成。这些信息使得Envoy能智能地根据指定的路由规则在目标实例中分发流量。
