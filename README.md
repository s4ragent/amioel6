# create oracle linux 6 AMI (HVM) on Amazon EC2
you need IAM role instance
you must edit awscli.sh if you don't use oregon region
    #Amazon Linux AMI 2013.09  change if you don't use oregon reqion
    ami=ami-5a20b86a


On IAM role instance
    git clone http://github.com/s4ragent/amioel6
    cd amioel6
    bash awscli.sh createbaseinstance
==> start worker instance

On worker instance
    sudo su -
    yum -y install git
    git clone http://github.com/s4ragent/amioel6
    cd amioel6
    bash osinstall.sh
    exit;

On IAM role instance
    cd amioel6
    bash awscli.sh createimage <worker-instance ami-id> /dev/sdf
==> create oracle linux 6 AMI(HVM) and you can delete worker instance
