#!/usr/bin/env bats

function setup() {
  source /troposphere/bin/activate
}

function teadown() {
  deactivate
}

@test "Make sure troposphere is installed" {
  pip list | grep troposphere
}

@test "Make sure boto3 is installed" {
  pip list | grep boto3
}

@test "Make sure pytest is installed" {
  pytest --version
}

@test "Make sure awscli is installed" {
  aws --version
}

@test "Make sure sam is installed" {
  sam --version
}

@test "Generate CloudFormation template" {
    python /tests/troposphere/lambda-bucket.py > /tests/troposphere/lambda-bucket-template.actual
    diff /tests/troposphere/lambda-bucket-template.expected /tests/troposphere/lambda-bucket-template.actual
}
