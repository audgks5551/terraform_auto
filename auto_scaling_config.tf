resource "aws_autoscaling_group" "asg-1" {
  desired_capacity   = 3  # 원하는 인스턴스 수
  max_size           = 5  # 최대 인스턴스 수
  min_size           = 2  # 최소 인스턴스 수

  # ELB 연결
  health_check_type = "ELB"
  target_group_arns = [aws_lb_target_group.auto-tg.arn]

  # 시작 템플릿 설정
  launch_template {
    id      = aws_launch_template.httpd-ec2.id
    version = "$Latest"
  }

  # 가능한 서브넷 설정
  vpc_zone_identifier = [aws_subnet.auto-public-subnet-1.id]

  # 태그 설정
  tag {
    key                 = "Name"
    value               = "${aws_vpc.auto-vpc.tags.Name}-asg"
    propagate_at_launch = true
  }
}

resource "aws_autoscaling_policy" "asp-1" {
  name                   = "${aws_vpc.auto-vpc.tags.Name}-asp-1"
  autoscaling_group_name = aws_autoscaling_group.asg-1.name
  policy_type            = "TargetTrackingScaling"

  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }
    target_value = 50.0
  }
}