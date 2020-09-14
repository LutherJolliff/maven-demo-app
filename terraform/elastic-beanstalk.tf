resource "aws_elastic_beanstalk_application" "elastic-bean-app" {
  name        = "${var.app}"
  description = ""
}

resource "aws_elastic_beanstalk_environment" "elastic-bean-env" {
  name                = "${var.environment}"
  application         = "${aws_elastic_beanstalk_application.elastic-bean-app.name}"
  solution_stack_name = "${var.appType}"
  
  setting {
    namespace = "aws:autoscaling:launchconfiguration"
    name = "IamInstanceProfile"
    value = "${aws_iam_instance_profile.elastic_bean_profile.name}"
  }
}
resource "aws_iam_instance_profile" "elastic_bean_profile" {
  name = "basic_profile_maven"
  role = "aws-elasticbeanstalk-ec2-role"
}