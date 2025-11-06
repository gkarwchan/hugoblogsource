+++
title = "Monorepos, Workspaces & Turborepo: A Modern JavaScript Development Architecture"
date = 2025-11-05T18:41:54-06:00
short = true
toc = true
draft = false
tags = ["javascript"]
categories = []
series = []
comment = true
+++

# Introduction

The JavaScript ecosystem has undergone a significant architectural shift in recent years. As applications grow more complex. Shifting away from two opposite architecure patterns:  
* Massive monolithic application
* or chaos of dozen separate repos.
A new rising pattern is gaining more ground in modern JavaScript applications.  
Monorepo pattern, where a single repo for all the code base, but at the same time separate and independent modules, which combine the best of two worlds:  
1. Independent development & testing for each module.
2. Having all code together, making solving dependencies, and reducing the size, time and effor of solving dependencies between these independant modules.

## The Monorepo Pattern: Best of Both Worlds

A **monorepo** (monolithic repository) is a single repository that contains multiple projects, applications, or packages. Unlike a monolithic application where everything is tightly coupled, a monorepo encourages indepandent modular design while keeping code centrally managed.

### Why Monorepos?

**Unified Versioning & Dependencies**  
All projects share the same dependency versions, eliminating the "works on my machine" problem and dependency hell across services.

**Atomic Changes Across Projects**  
Need to update an API and all the frontends that consume it? Make one commit, one pull request. No orchestrating changes across multiple repositories.

**Code Reusability**  
Shared utilities, UI components, types, and configurations can be easily consumed across projects without publishing to npm or dealing with version management.

**Simplified Developer Experience**  
One clone, one install, one place to search for code. New developers can understand the entire system architecture by exploring a single repository.

**Refactoring with Confidence**  
Modern IDEs can find all usages across the entire codebase. Refactor a shared function and immediately see every place it's used.

### The Challenge

While monorepos solve many problems, they introduce new challenges:
- Build times grow as the codebase expands
- Running tests for everything on every change is inefficient
- CI/CD pipelines become slower
- Task orchestration becomes complex (what needs to build before what?)

This is where workspaces and Turborepo enter the picture.

## Workspaces: The Glue

**Workspaces** are a feature provided by package managers (npm, yarn, pnpm) that make monorepos practical. They are the glue that link all packages together. They solve the fundamental problem of managing multiple packages within a single repository.

### How Workspaces Work

In your root `package.json`, you define workspace patterns:

```json
{
  "name": "my-monorepo",
  "private": true,
  "workspaces": [
    "apps/*",
    "packages/*"
  ],

}
```

This tells your package manager that `apps/web`, `apps/api`, `packages/ui`, etc., are all separate packages that should be managed together.

### What Workspaces Provide

**Hoisted Dependencies**  
Common dependencies are installed once at the root, saving disk space and installation time. Packages share `node_modules` when possible.

**Local Package Linking**  
Packages can depend on each other without publishing to npm. Changes are immediately reflected across the monorepo.

```json
// apps/web/package.json
{
  "dependencies": {
    "@myapp/ui": "*",
    "@myapp/utils": "*"
  }
}
```

**Simplified Scripts**  
Package managers provide commands to run scripts across workspaces:


```json
// apps/web/package.json
{
  "scripts": {
    "buildAll": "npm run build --workspaces",
    "testOnePackage": "pnpm run test --filter"
  }
}
```
And then you can test one package only by running

```bash
pnpm run testOnePackage -- "./packages/*"
```

### The Gap Workspaces Don't Fill

While workspaces solve dependency management and linking, they don't address:
- **Task orchestration** - Understanding which packages need to build in what order
- **Incremental execution** - Skipping tasks when nothing changed
- **Caching** - Reusing previous build artifacts
- **Parallelization** - Intelligently running tasks concurrently
- **Remote caching** - Sharing build results across team members and CI

This is exactly what Turborepo was designed to solve.

## Turborepo: The Orchestration Layer

**Turborepo** sits on top of your workspace setup and acts as an intelligent task runner. It doesn't replace workspaces—it enhances them.

### The Turborepo Philosophy

Turborepo operates on a simple but powerful principle: **never do the same work twice**. It achieves this through:

1. **Content-aware hashing** - Understanding what inputs affect each task
2. **Local caching** - Storing task outputs on your machine
3. **Remote caching** - Sharing cached results across your team
4. **Dependency graph analysis** - Understanding package relationships
5. **Parallel execution** - Running independent tasks simultaneously

### Setting Up Turborepo

Installation is straightforward:

```bash
npm install turbo --save-dev
```

Create a `turbo.json` at your repository root:

```json
{
  "$schema": "https://turbo.build/schema.json",
  "pipeline": {
    "build": {
      "dependsOn": ["^build"],
      "outputs": ["dist/**", ".next/**"]
    },
    "test": {
      "dependsOn": ["build"],
      "inputs": ["src/**", "test/**"]
    },
    "lint": {
      "outputs": []
    },
    "dev": {
      "cache": false,
      "persistent": true
    }
  }
}
```

### Understanding the Pipeline

The `pipeline` configuration is where Turborepo's magic happens:

**`dependsOn: ["^build"]`**  
The `^` means "wait for dependencies to build first." If `@myapp/web` depends on `@myapp/ui`, Turborepo ensures `@myapp/ui` builds before `@myapp/web`.

**`outputs: ["dist/**"]`**  
Tells Turborepo what files to cache. When these outputs are cached and inputs haven't changed, the task is skipped entirely.

**`inputs`**  
Explicitly define what files affect a task. By default, Turborepo uses all files in the package.

### Running Tasks

```bash
# Rebuild all, but only rebuild changed package
turbo run build

# Run tests, leveraging cache
turbo run test

# Build only a specific app and its dependencies
turbo run build --filter=@myapp/web

# Build everything that changed since main branch
turbo run build --filter=...[main]

# Cache hits across machines = instant builds
turbo build --remote-cache

```



### The Speed Advantage

On the first run, Turborepo executes all tasks normally. But on subsequent runs:

```
Tasks:    8 successful, 8 total
Cached:   7 successful, 7 total
Time:     0.523s >>> FULL TURBO ⚡
```

Seven out of eight tasks were skipped because nothing changed. Your 5-minute build just became half a second.

## How It All Works Together

Let's walk through a real-world example of how monorepos, workspaces, and Turborepo create a seamless development experience.  

I am going to show a structure that you might see it in many projects, because it is the initial structure created by `create-turbo` starter application, and adopted by `Vercel` community and `Next.js`.  

### Repository Structure

```
my-monorepo/
├── apps/
│   ├── web/              # Next.js frontend
│   ├── admin/            # Admin dashboard
│   └── api/              # Express backend
├── packages/
│   ├── ui/               # Shared React components
│   ├── utils/            # Common utilities
│   ├── types/            # TypeScript types
│   └── config/           # Shared configs (ESLint, TS, etc.)
├── package.json          # Root package.json with workspaces
├── turbo.json            # Turborepo configuration
└── pnpm-workspace.yaml   # pnpm workspace config
```

### The root package.json:
```json
{
  "name": "my-turborepo",
  "private": true,
  "workspaces": ["apps/*", "packages/*"],
  "scripts": {
    "build": "turbo build",
    "dev": "turbo dev",
    "test": "turbo test",
    "clean": "turbo clean"
  },
  "devDependencies": {
    "turbo": "latest"
  }
}
```
### Dependency in dependent pakcage.json

```json
// packages/ui/package.json
{
  "name": "@my-company/ui",
  "dependencies": {
    "@my-company/utils": "workspace:*"
  }
}
```

### turbo.json

```json
{
  "pipeline": {
    "build": {
      "dependsOn": ["^build"],
      "outputs": [".next/**", "dist/**"]
    },
    "dev": {
      "cache": false,
      "persistent": true
    },
    "test": {
      "dependsOn": ["build"]
    },
    "lint": {
      "outputs": []
    }
  }
}
```

**Developer Makes a Change**

A developer updates a Button component in `packages/ui`:

```bash
# Make changes to packages/ui/src/Button.tsx
turbo run build --filter=...@myapp/ui
```

Turborepo:
1. Detects that `@myapp/ui` changed
2. Automatically includes `@myapp/web` and `@myapp/admin` (dependents)
3. Skips `@myapp/api` (unaffected)
4. Builds in optimal order
5. Caches all outputs

**CI/CD Pipeline**

In your GitHub Actions workflow:

```yaml
- name: Build
  run: turbo run build --filter=[HEAD^1]
```

Turborepo:
1. Analyzes what changed in the commit
2. Only builds affected packages
3. Pulls cached artifacts from remote cache for unchanged packages
4. Dramatically reduces CI time

**Team Collaboration**

When a teammate pulls the latest code:

```bash
turbo run build
```

Turborepo:
1. Checks remote cache for matching build artifacts
2. Downloads cached results for packages they didn't change
3. Only builds packages that differ from cached versions
4. The entire team benefits from each other's work

## Real-World Benefits

### Performance Gains

Teams report:
- **70-90% reduction** in CI/CD times
- **Local builds** completing in seconds instead of minutes
- **Remote cache hit rates** of 80%+ for typical development

### Developer Experience

- **Instant feedback** on changes
- **Confidence in refactoring** across package boundaries
- **Simplified onboarding** for new developers
- **Consistent tooling** across all projects

### Scalability

- Monorepos scaling to **hundreds of packages**
- **Large teams** collaborating without stepping on each other
- **Microservices-style benefits** without microservices complexity

## Best Practices

### Structure for Success

**Keep packages focused** - Each package should have a single, clear responsibility

**Define clear boundaries** - Use TypeScript and explicit exports to enforce module boundaries

**Shared configuration** - Create `@myapp/config` packages for ESLint, TypeScript, etc.

**Progressive enhancement** - Start with a few packages, split further as needed

### Optimize Turborepo

**Be specific with outputs** - Only cache what's necessary

**Use filters effectively** - Don't rebuild everything in CI

**Configure remote caching** - Use Vercel's free tier or set up your own

**Monitor cache effectiveness** - Pay attention to cache hit rates

### Avoid Common Pitfalls

**Don't over-modularize** - Too many packages creates unnecessary complexity

**Watch for circular dependencies** - Turborepo will error, but prevent them at design time

**Be mindful of bundle sizes** - Shared packages can bloat if not tree-shakeable

**Keep build times reasonable** - If individual package builds are slow, no amount of caching will help

## Conclusion

The combination of monorepos, workspaces, and Turborepo represents a mature approach to managing complex JavaScript applications. It's not about choosing between monoliths and microservices—it's about getting the benefits of both.

**Workspaces** provide the foundation for managing multiple packages in a single repository. **Turborepo** adds the intelligence to make that monorepo fast, efficient, and scalable. Together, they enable teams to build modular applications with the simplicity of a monolith and the architectural clarity of distributed services.

Whether you're building a startup's first product or managing a large enterprise application, this architectural pattern is worth serious consideration. The initial setup investment pays dividends in developer productivity, code quality, and deployment confidence.

The future of JavaScript development isn't about picking the "right" architecture—it's about having the tools to adapt as your needs evolve. Monorepos with Turborepo give you exactly that flexibility.

---

*Ready to try it yourself? Start with a simple two-package setup and experience the difference. You might never go back to managing multiple repositories again.*