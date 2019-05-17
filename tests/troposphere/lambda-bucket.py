from troposphere import Template, Parameter, Ref, GetAtt, Join
from troposphere import s3, kms


def get_cf_template():
    t = Template()
    t.set_description('Creates an S3 bucket that can be used when uploading lambda packages')

    bucket_name_param = t.add_parameter(Parameter(
        'BucketName',
        Description='Name of the S3 bucket that will contain lambda packages',
        Type='String',
    ))

    lambda_bucket = s3.Bucket(
        'LambdaBucket',
        BucketName=Ref(bucket_name_param),
        BucketEncryption=s3.BucketEncryption(
            ServerSideEncryptionConfiguration=[
                s3.ServerSideEncryptionRule(
                    ServerSideEncryptionByDefault=s3.ServerSideEncryptionByDefault(
                        # KMSMasterKeyID=,
                        # SSEAlgorithm='aws:kms',  # AES256
                        SSEAlgorithm='AES256',
                    )
                )
            ]
        ),
        VersioningConfiguration=s3.VersioningConfiguration(
            Status='Enabled',
        )
    )
    t.add_resource(lambda_bucket)

    return t.to_yaml()


def main():
    print(get_cf_template())


if __name__ == "__main__":
    main()
