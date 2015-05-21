# create oracle linux 6 AMI (HVM) on Amazon EC2
you need IAM role instance 

On IAM role instance
    
    git clone http://github.com/s4ragent/amioel6
    cd amioel6
    # you must edit awscli.sh if you don't use oregon region
    # ami=ami-5a20b86a <<== edit
    bash awscli.sh createbaseinstance
==> start worker instance

On worker instance

    sudo su -
    yum -y install git
    git clone http://github.com/s4ragent/amioel6
    cd amioel6
    bash osinstall.sh

On IAM role instance

    cd amioel6
    bash awscli.sh createimage <worker-instance ami-id> /dev/sdf
    Ex) bash awscli.sh createimage i-332da0c4 /dev/sdf
==> create oracle linux 6 AMI(HVM) and you can delete worker instance
