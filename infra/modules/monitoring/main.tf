data "aws_region" "current" {}

resource "aws_sns_topic" "alerts" {
  name = "${var.name}-alerts"
}

resource "aws_sns_topic_subscription" "email" {
  topic_arn = aws_sns_topic.alerts.arn
  protocol  = "email"
  endpoint  = var.alert_email
}

locals {
  alarms = {
    node-cpu-high = {
      metric    = "node_cpu_utilization"
      stat      = "Average"
      threshold = 80
      dims      = tomap({ ClusterName = var.cluster_name })
    }
    node-memory-high = {
      metric    = "node_memory_utilization"
      stat      = "Average"
      threshold = 80
      dims      = tomap({ ClusterName = var.cluster_name })
    }
    failed-nodes = {
      metric    = "cluster_failed_node_count"
      stat      = "Maximum"
      threshold = 0
      dims      = tomap({ ClusterName = var.cluster_name })
    }
    pod-restarts = {
      metric    = "pod_number_of_container_restarts"
      stat      = "Sum"
      threshold = 2
      dims = tomap({
        ClusterName = var.cluster_name
        Namespace   = var.namespace
        Service     = var.service
      })
    }
  }
}

resource "aws_cloudwatch_metric_alarm" "this" {
  for_each = local.alarms

  alarm_name          = "${var.name}-${each.key}"
  namespace           = "ContainerInsights"
  metric_name         = each.value.metric
  dimensions          = each.value.dims
  statistic           = each.value.stat
  period              = 300
  evaluation_periods  = 2
  threshold           = each.value.threshold
  comparison_operator = "GreaterThanThreshold"
  treat_missing_data  = "notBreaching"
  alarm_actions       = [aws_sns_topic.alerts.arn]
  ok_actions          = [aws_sns_topic.alerts.arn]
}

resource "aws_cloudwatch_dashboard" "this" {
  dashboard_name = "${var.name}-overview"

  dashboard_body = jsonencode({
    widgets = [
      {
        type = "metric", x = 0, y = 0, width = 12, height = 6
        properties = {
          title   = "Node CPU %", region = data.aws_region.current.region, view = "timeSeries", stat = "Average", period = 300
          metrics = [["ContainerInsights", "node_cpu_utilization", "ClusterName", var.cluster_name]]
        }
      },
      {
        type = "metric", x = 12, y = 0, width = 12, height = 6
        properties = {
          title   = "Node memory %", region = data.aws_region.current.region, view = "timeSeries", stat = "Average", period = 300
          metrics = [["ContainerInsights", "node_memory_utilization", "ClusterName", var.cluster_name]]
        }
      },
      {
        type = "metric", x = 0, y = 6, width = 12, height = 6
        properties = {
          title   = "App container restarts", region = data.aws_region.current.region, view = "timeSeries", stat = "Sum", period = 300
          metrics = [["ContainerInsights", "pod_number_of_container_restarts", "ClusterName", var.cluster_name, "Namespace", var.namespace, "Service", var.service]]
        }
      },
      {
        type = "metric", x = 12, y = 6, width = 12, height = 6
        properties = {
          title   = "Cluster node count", region = data.aws_region.current.region, view = "timeSeries", stat = "Maximum", period = 300
          metrics = [["ContainerInsights", "cluster_node_count", "ClusterName", var.cluster_name]]
        }
      }
    ]
  })
}
