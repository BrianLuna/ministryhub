# MinistryHub

**MinistryHub** is a platform designed to help organize ministries composed of churches, enabling the management of volunteers, roles, leaders, deacons, people, small groups, calendars, locations, and more.

---

## 🚀 Core Technologies

### 🔧 Project Base

- **TypeScript**
- **Monorepo with Turborepo**
- **pnpm** as the package manager
- **Turbopack** as the bundler for `web`

### 🌐 Frontend

- **React**
- **Next.js (App Router + RSC)**
- **TailwindCSS**
- **shadcn/ui**
- **Zustand** for local state management
- **TanStack Query** for remote state and backend synchronization
- **next-themes** for dark/light mode support

### 🧠 Backend

- **Node.js**
- **Fastify** as the HTTP framework
- **tRPC** for fullstack type-safe communication (no REST or GraphQL needed)
- **Drizzle ORM** for database access
- **PostgreSQL** running locally via Docker
- **Redis** for caching and event queues (running locally via Docker)

### 🔐 Authentication

- **Clerk** for user and session management (free tier)

### ⚙️ Development Environment

- **Docker** for containerization
- **Docker Compose** for local service orchestration
- **Kubernetes** for local development and learning
  - Minikube for local K8s cluster
  - kubectl for cluster management
  - Helm for package management
  - Kustomize for configuration management
- **Local Development**:
  - Frontend: `localhost:3000`
  - Backend: `localhost:4000`
  - PostgreSQL: `localhost:5432`
  - Redis: `localhost:6379`

### 🧪 Testing

- **Jest** for unit testing
- **Playwright** for end-to-end testing

### 🧹 Validation

- **Zod** for schema validation on both frontend and backend

### 📦 Version Control

- **Git + Gitflow**
- **GitHub** as the code hosting platform

---

## 📁 Monorepo Structure (Turbo)

```plaintext
ministryhub/
├── apps/                    # Application code
│   ├── web/                # Next.js frontend
│   │   ├── src/           # Source code
│   │   │   ├── app/      # App router pages
│   │   │   ├── components/# React components
│   │   │   └── lib/      # Utility functions
│   │   ├── public/        # Static assets
│   │   └── package.json   # Frontend dependencies
│   └── api/               # Fastify backend
│       ├── src/           # Source code
│       │   ├── routes/   # API routes
│       │   ├── services/ # Business logic
│       │   └── lib/      # Utility functions
│       └── package.json   # Backend dependencies
│
├── packages/               # Shared packages
│   ├── db/                # Database package
│   │   ├── src/          # Database code
│   │   ├── migrations/   # Drizzle migrations
│   │   └── package.json  # DB package dependencies
│   └── config/           # Shared configurations
│       ├── eslint/       # ESLint configs
│       ├── typescript/   # TS configs
│       └── package.json  # Config package dependencies
│
├── docker/              # Docker-related files
│   ├── web/            # Frontend Dockerfile
│   ├── api/            # Backend Dockerfile
│   └── db/             # Database Dockerfile
│
├── docs/              # Project documentation
│   ├── architecture/  # Architecture diagrams
│   ├── api/          # API documentation
│   └── k8s/          # Kubernetes documentation
│
├── .github/          # GitHub configurations
│   ├── workflows/    # GitHub Actions
│   └── templates/    # PR and issue templates
│
├── .vscode/         # VS Code settings
├── docker-compose.yml # Local development compose file
├── pnpm-workspace.yaml # PNPM workspace config
├── turbo.json       # Turborepo config
├── tsconfig.json    # TypeScript config
├── drizzle.config.ts # Database config
├── eslint.config.mjs # ESLint config
├── prettier.config.js # Prettier config
└── package.json     # Root package.json
```

### Key Directories Explained

1. **`apps/`**: Contains the main applications
   - `web/`: Next.js frontend application
   - `api/`: Fastify backend application

2. **`packages/`**: Shared code and configurations
   - `db/`: Database package with migrations
   - `config/`: Shared configurations for TypeScript, ESLint, etc.

3. **`k8s/`**: Kubernetes configurations
   - `base/`: Base Kubernetes manifests
   - `overlays/`: Environment-specific configurations
   - `helm/`: Helm charts for deployment

4. **`scripts/`**: Development and deployment scripts
   - Setup scripts
   - Deployment scripts
   - Kubernetes-specific scripts

5. **`docker/`**: Docker-related files
   - Separate Dockerfiles for each service
   - Docker-specific configurations

6. **`docs/`**: Project documentation
   - Architecture documentation
   - API documentation
   - Kubernetes setup guides

7. **`.github/`**: GitHub-specific configurations
   - GitHub Actions workflows
   - PR and issue templates

This structure provides:
- Clear separation of concerns
- Easy navigation
- Scalability for future additions
- Support for both local and Kubernetes development
- Comprehensive documentation
- Automated workflows

## 🚀 Running the Application

### 1. Prerequisites Setup

1. **Install Required Tools**:
   ```bash
   # Install pnpm if you haven't already
   npm install -g pnpm
   
   # Install dependencies
   pnpm install
   ```

2. **Set Up Clerk Authentication**:
   1. Go to [Clerk Dashboard](https://dashboard.clerk.dev/)
   2. Create a new application
   3. Get your API keys from the Clerk dashboard
   4. Create a `.env` file in the root directory with the following variables:
      ```env
      # Frontend (.env.local in apps/web)
      NEXT_PUBLIC_CLERK_PUBLISHABLE_KEY=your_publishable_key
      CLERK_SECRET_KEY=your_secret_key
      
      # Backend (.env in apps/api)
      CLERK_SECRET_KEY=your_secret_key
      ```

### 2. Start the Development Environment

1. **Start the Database**:
   ```bash
   docker-compose up -d
   ```

2. **Run Database Migrations**:
   ```bash
   pnpm db:migrate
   ```

3. **Start the Development Servers**:
   ```bash
   # In one terminal
   pnpm dev:web
   
   # In another terminal
   pnpm dev:api
   ```

### 3. Access the Application

- Frontend: http://localhost:3000
- Backend: http://localhost:4000

### 4. Authentication Flow

1. **Sign Up**:
   - Navigate to http://localhost:3000/sign-up
   - Create a new account using email or social providers
   - Verify your email if required

2. **Sign In**:
   - Navigate to http://localhost:3000/sign-in
   - Use your credentials to log in
   - You'll be redirected to the dashboard after successful authentication

### 5. Development Notes

- The application currently supports sign-in and sign-up functionality
- Additional features are under development
- Make sure to keep your Clerk API keys secure and never commit them to version control
- For local development, use the Clerk development environment
- The application supports theme mode toggling (dark/light) using the theme switcher in the navigation bar
  - Theme preference is persisted in local storage
  - System theme detection is supported
  - Smooth transitions between themes

## 🚀 Getting Started

1. **Prerequisites**:
   - Node.js (LTS version)
   - pnpm
   - Docker and Docker Compose
   - Git
   - kubectl
   - Minikube
   - Helm

2. **Local Development Setup**:
   - Clone the repository
   - Install dependencies: `pnpm install`
   - Choose your development environment:
     
     **Option 1: Docker Compose (Simpler)**
     - Start local services: `docker-compose up -d`
     - Run development servers:
       - Frontend: `pnpm dev:web`
       - Backend: `pnpm dev:api`
     
     **Option 2: Kubernetes (Learning)**
     - Start Minikube: `minikube start`
     - Deploy to K8s: `kubectl apply -k k8s/overlays/dev`
     - Access services:
       - Frontend: `minikube service web`
       - Backend: `minikube service api`

3. **Environment Variables**:
   - Copy `.env.example` to `.env`
   - Configure Clerk credentials
   - Set up database connection details

4. **Database**:
   - PostgreSQL runs locally via Docker or K8s
   - Use Drizzle migrations for schema management
   - Access via `localhost:5432`

5. **Authentication**:
   - Uses Clerk's free tier
   - Configure in your Clerk dashboard
   - Set up environment variables

## 📚 Learning Resources

### Kubernetes
- [Kubernetes Documentation](https://kubernetes.io/docs/home/)
- [Minikube Documentation](https://minikube.sigs.k8s.io/docs/)
- [Helm Documentation](https://helm.sh/docs/)
- [Kustomize Documentation](https://kustomize.io/)

### Project-Specific K8s Learning
- Basic concepts: Pods, Services, Deployments
- Configuration: ConfigMaps, Secrets
- Storage: PersistentVolumes, PersistentVolumeClaims
- Networking: Services, Ingress
- Scaling: HorizontalPodAutoscaler
- Monitoring: Metrics Server, Prometheus
