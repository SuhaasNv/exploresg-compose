# ExploreSG DigitalOcean Deployment Architecture

## 🏗️ Infrastructure Overview

```
┌─────────────────────────────────────────────────────────────────┐
│                        DigitalOcean Cloud                        │
├─────────────────────────────────────────────────────────────────┤
│  ┌─────────────────┐    ┌─────────────────┐    ┌─────────────┐ │
│  │   VPC Network   │    │   Firewall      │    │   Volume    │ │
│  │  10.10.0.0/16   │    │   Rules         │    │   20GB      │ │
│  └─────────────────┘    └─────────────────┘    └─────────────┘ │
│           │                       │                       │      │
│           └───────────────────────┼───────────────────────┘      │
│                                   │                              │
│  ┌─────────────────────────────────────────────────────────────┐ │
│  │                Ubuntu 22.04 Droplet                         │ │
│  │              (s-1vcpu-1gb)                                  │ │
│  │                                                             │ │
│  │  ┌─────────────────────────────────────────────────────────┐ │ │
│  │  │              Docker Compose Stack                       │ │ │
│  │  │                                                         │ │ │
│  │  │  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐    │ │ │
│  │  │  │  Frontend   │  │    Auth     │  │   Fleet     │    │ │ │
│  │  │  │   :3000     │  │   :8081     │  │   :8082     │    │ │ │
│  │  │  └─────────────┘  └─────────────┘  └─────────────┘    │ │ │
│  │  │                                                         │ │ │
│  │  │  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐    │ │ │
│  │  │  │  Booking    │  │  Payment    │  │ PostgreSQL  │    │ │ │
│  │  │  │   :8083     │  │   :8084     │  │   :5432     │    │ │ │
│  │  │  └─────────────┘  └─────────────┘  └─────────────┘    │ │ │
│  │  └─────────────────────────────────────────────────────────┘ │ │
│  └─────────────────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────────────┘
```

## 🔄 CI/CD Pipeline

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   GitHub Repo   │    │  GitHub Actions │    │  DigitalOcean   │
│                 │    │                 │    │                 │
│  ┌─────────────┐│    │  ┌─────────────┐│    │  ┌─────────────┐│
│  │   Service   ││───▶│  │   Build &   ││───▶│  │   Droplet   ││
│  │   Code      ││    │  │   Push to   ││    │  │             ││
│  └─────────────┘│    │  │ Docker Hub  ││    │  └─────────────┘│
│                 │    │  └─────────────┘│    │                 │
│  ┌─────────────┐│    │                 │    │  ┌─────────────┐│
│  │  Compose    ││───▶│  ┌─────────────┐│───▶│  │  Deploy    ││
│  │  Repo       ││    │  │   Deploy    ││    │  │  Script    ││
│  └─────────────┘│    │  │  Workflow   ││    │  └─────────────┘│
└─────────────────┘    └─────────────────┘    └─────────────────┘
```

## 🌐 Network Architecture

```
Internet
    │
    ▼
┌─────────────────────────────────────────────────────────────┐
│                    DigitalOcean                            │
│                                                             │
│  ┌─────────────────────────────────────────────────────┐   │
│  │                Floating IP                           │   │
│  │            (Public IP Address)                      │   │
│  └─────────────────────────────────────────────────────┘   │
│                           │                               │
│  ┌─────────────────────────────────────────────────────┐   │
│  │                  Firewall                           │   │
│  │  ┌─────────┐ ┌─────────┐ ┌─────────┐ ┌─────────┐ │   │
│  │  │   SSH   │ │  HTTP    │ │  Auth   │ │  APIs    │ │   │
│  │  │  :22    │ │  :3000   │ │ :8081-4 │ │  :8081-4 │ │   │
│  │  └─────────┘ └─────────┘ └─────────┘ └─────────┘ │   │
│  └─────────────────────────────────────────────────────┘   │
│                           │                               │
│  ┌─────────────────────────────────────────────────────┐   │
│  │                VPC Network                          │   │
│  │              10.10.0.0/16                          │   │
│  │                                                     │   │
│  │  ┌─────────────────────────────────────────────┐   │   │
│  │  │              Droplet                        │   │   │
│  │  │         (Ubuntu 22.04)                      │   │   │
│  │  │                                             │   │   │
│  │  │  ┌─────────────────────────────────────┐   │   │   │
│  │  │  │        Docker Compose               │   │   │   │
│  │  │  │                                     │   │   │   │
│  │  │  │  ┌─────────┐ ┌─────────┐ ┌─────────┐│   │   │   │
│  │  │  │  │Frontend │ │  Auth   │ │  Fleet  ││   │   │   │
│  │  │  │  │  :3000  │ │  :8081  │ │  :8082  ││   │   │   │
│  │  │  │  └─────────┘ └─────────┘ └─────────┘│   │   │   │
│  │  │  │                                     │   │   │   │
│  │  │  │  ┌─────────┐ ┌─────────┐ ┌─────────┐│   │   │   │
│  │  │  │  │ Booking │ │ Payment │ │Postgres ││   │   │   │
│  │  │  │  │  :8083  │ │  :8084  │ │  :5432  ││   │   │   │
│  │  │  │  └─────────┘ └─────────┘ └─────────┘│   │   │   │
│  │  │  └─────────────────────────────────────┘   │   │   │
│  │  └─────────────────────────────────────────────┘   │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                             │
│  ┌─────────────────────────────────────────────────────┐   │
│  │                Persistent Volume                    │   │
│  │                  (20GB)                            │   │
│  │              (PostgreSQL Data)                     │   │
│  └─────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────┘
```

## 🔧 Service Dependencies

```
┌─────────────┐    ┌─────────────┐    ┌─────────────┐
│  Frontend   │───▶│    Auth     │───▶│ PostgreSQL │
│   :3000     │    │   :8081     │    │   :5432    │
└─────────────┘    └─────────────┘    └─────────────┘
       │                   │                   │
       ▼                   ▼                   ▼
┌─────────────┐    ┌─────────────┐    ┌─────────────┐
│   Fleet     │───▶│  Booking    │───▶│  Payment   │
│   :8082     │    │   :8083     │    │   :8084     │
└─────────────┘    └─────────────┘    └─────────────┘
```

## 📊 Monitoring & Health Checks

```
┌─────────────────────────────────────────────────────────────┐
│                    Health Monitoring                        │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐        │
│  │  Frontend   │  │    Auth     │  │   Fleet     │        │
│  │  Health     │  │  Health     │  │  Health     │        │
│  │  :3000      │  │  :8081      │  │  :8082      │        │
│  └─────────────┘  └─────────────┘  └─────────────┘        │
│                                                             │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐        │
│  │  Booking    │  │  Payment    │  │ PostgreSQL  │        │
│  │  Health     │  │  Health     │  │  Health     │        │
│  │  :8083      │  │  :8084      │  │  :5432      │        │
│  └─────────────┘  └─────────────┘  └─────────────┘        │
└─────────────────────────────────────────────────────────────┘
```

## 🚀 Deployment Flow

1. **Infrastructure Provisioning**
   - Terraform creates VPC, Droplet, Firewall, Volume
   - Floating IP assigned for public access

2. **Droplet Provisioning**
   - Ansible installs Docker, Docker Compose
   - Creates application directories
   - Sets up systemd services

3. **Application Deployment**
   - Docker Compose pulls images from Docker Hub
   - Services start with health checks
   - Database auto-seeds with initial data

4. **CI/CD Integration**
   - GitHub Actions build and push images
   - Automated deployment on code changes
   - Health checks verify deployment success

## 🔒 Security Features

- **Firewall Rules**: Only necessary ports exposed
- **VPC Isolation**: Private network for services
- **SSH Key Authentication**: No password-based access
- **Volume Encryption**: Data at rest protection
- **Container Security**: Read-only filesystems, limited capabilities

## 📈 Scalability Considerations

- **Horizontal Scaling**: Add more droplets behind load balancer
- **Vertical Scaling**: Upgrade droplet size
- **Database Scaling**: Separate database instance
- **CDN Integration**: CloudFlare or DigitalOcean Spaces
- **Monitoring**: Prometheus + Grafana stack
