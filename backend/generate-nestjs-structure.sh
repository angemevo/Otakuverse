#!/bin/bash
# generate-nestjs-structure.sh
# Script pour générer la structure complète du backend NestJS + Supabase
#
# Usage: bash generate-nestjs-structure.sh

echo "🚀 Génération de la structure NestJS + Supabase..."

# Créer le dossier racine
mkdir -p otakuverse-nestjs
cd otakuverse-nestjs

# ============================================
# FICHIERS RACINE
# ============================================

# package.json
cat > package.json << 'EOF'
{
  "name": "otakuverse-backend",
  "version": "1.0.0",
  "description": "Backend API NestJS pour Otakuverse",
  "scripts": {
    "start": "nest start",
    "start:dev": "nest start --watch",
    "start:debug": "nest start --debug --watch",
    "start:prod": "node dist/main",
    "build": "nest build",
    "format": "prettier --write \"src/**/*.ts\"",
    "lint": "eslint \"{src,apps,libs,test}/**/*.ts\" --fix"
  },
  "dependencies": {
    "@nestjs/common": "^10.3.0",
    "@nestjs/core": "^10.3.0",
    "@nestjs/platform-express": "^10.3.0",
    "@nestjs/config": "^3.1.1",
    "@nestjs/jwt": "^10.2.0",
    "@nestjs/passport": "^10.0.3",
    "@supabase/supabase-js": "^2.45.0",
    "passport": "^0.7.0",
    "passport-jwt": "^4.0.1",
    "bcryptjs": "^2.4.3",
    "class-validator": "^0.14.1",
    "class-transformer": "^0.5.1",
    "reflect-metadata": "^0.2.1",
    "rxjs": "^7.8.1"
  },
  "devDependencies": {
    "@nestjs/cli": "^10.3.0",
    "@nestjs/schematics": "^10.1.0",
    "@types/node": "^20.11.0",
    "@types/passport-jwt": "^4.0.1",
    "@types/bcryptjs": "^2.4.6",
    "@typescript-eslint/eslint-plugin": "^6.19.0",
    "@typescript-eslint/parser": "^6.19.0",
    "eslint": "^8.56.0",
    "prettier": "^3.2.4",
    "typescript": "^5.3.3"
  }
}
EOF

# tsconfig.json
cat > tsconfig.json << 'EOF'
{
  "compilerOptions": {
    "module": "commonjs",
    "declaration": true,
    "removeComments": true,
    "emitDecoratorMetadata": true,
    "experimentalDecorators": true,
    "allowSyntheticDefaultImports": true,
    "target": "ES2021",
    "sourceMap": true,
    "outDir": "./dist",
    "baseUrl": "./",
    "incremental": true,
    "skipLibCheck": true,
    "strictNullChecks": true,
    "noImplicitAny": false,
    "strictBindCallApply": false,
    "forceConsistentCasingInFileNames": false,
    "noFallthroughCasesInSwitch": false,
    "paths": {
      "@/*": ["src/*"]
    }
  }
}
EOF

# nest-cli.json
cat > nest-cli.json << 'EOF'
{
  "$schema": "https://json.schemastore.org/nest-cli",
  "collection": "@nestjs/schematics",
  "sourceRoot": "src",
  "compilerOptions": {
    "deleteOutDir": true
  }
}
EOF

# .env.example
cat > .env.example << 'EOF'
# Application
PORT=3000
NODE_ENV=development

# Supabase
SUPABASE_URL=https://xxxxx.supabase.co
SUPABASE_SERVICE_ROLE_KEY=your_service_role_key_here

# JWT
JWT_SECRET=your_jwt_secret_here
JWT_EXPIRES_IN=7d
EOF

# .env
cat > .env << 'EOF'
PORT=3000
NODE_ENV=development
SUPABASE_URL=
SUPABASE_SERVICE_ROLE_KEY=
JWT_SECRET=
JWT_EXPIRES_IN=7d
EOF

# .gitignore
cat > .gitignore << 'EOF'
# Dependencies
node_modules/
dist/

# Environment
.env
.env.local
.env.*.local

# IDE
.vscode/
.idea/
*.swp
*.swo

# Logs
*.log
npm-debug.log*

# OS
.DS_Store
Thumbs.db
EOF

# README.md
cat > README.md << 'EOF'
# Otakuverse Backend - NestJS

Backend API NestJS avec Supabase pour Otakuverse.

## Installation

```bash
npm install
```

## Configuration

1. Créez `.env` depuis `.env.example`
2. Remplissez vos credentials Supabase
3. Générez un JWT_SECRET

## Démarrage

```bash
# Développement
npm run start:dev

# Production
npm run build
npm run start:prod
```

## Structure

- `src/auth/` - Authentification JWT
- `src/users/` - Gestion utilisateurs
- `src/posts/` - Gestion posts
- `src/database/` - Connexion Supabase
- `src/common/` - Utilitaires partagés

## API

- `POST /auth/signup` - Inscription
- `POST /auth/signin` - Connexion
- `GET /auth/me` - Profil actuel
- `GET /users/:id` - Détails utilisateur
- `PUT /users/:id` - Modifier utilisateur
- `GET /posts` - Liste posts
- `POST /posts` - Créer post
EOF

# ============================================
# SRC/
# ============================================

mkdir -p src

# main.ts
cat > src/main.ts << 'EOF'
// TODO: Point d'entrée de l'application
// - Bootstrap NestJS app
// - Configuration CORS
// - Configuration globale pipes/filters
// - Démarrage serveur
EOF

# app.module.ts
cat > src/app.module.ts << 'EOF'
// TODO: Module racine
// - Import ConfigModule
// - Import DatabaseModule
// - Import AuthModule
// - Import UsersModule
// - Import PostsModule
EOF

# app.controller.ts
cat > src/app.controller.ts << 'EOF'
// TODO: Controller racine pour health check
EOF

# app.service.ts
cat > src/app.service.ts << 'EOF'
// TODO: Service racine
EOF

# ============================================
# DATABASE/
# ============================================

mkdir -p src/database

cat > src/database/database.module.ts << 'EOF'
// TODO: Module de connexion Supabase
// - Provider SupabaseService
// - Export pour utilisation globale
EOF

cat > src/database/supabase.service.ts << 'EOF'
// TODO: Service Supabase
// - Créer et exporter client Supabase
// - Méthodes utilitaires DB
EOF

# ============================================
# COMMON/
# ============================================

mkdir -p src/common/decorators
mkdir -p src/common/filters
mkdir -p src/common/interceptors
mkdir -p src/common/guards

cat > src/common/decorators/current-user.decorator.ts << 'EOF'
// TODO: Decorator @CurrentUser()
// - Extraire l'utilisateur depuis le JWT
// - Utilisation: @CurrentUser() user: User
EOF

cat > src/common/filters/http-exception.filter.ts << 'EOF'
// TODO: Global exception filter
// - Formater les erreurs HTTP
// - Logger les erreurs
EOF

cat > src/common/interceptors/transform.interceptor.ts << 'EOF'
// TODO: Transform response interceptor
// - Formater les réponses API
// - Ajouter metadata (timestamp, etc.)
EOF

cat > src/common/guards/jwt-auth.guard.ts << 'EOF'
// TODO: JWT Auth Guard
// - Vérifier le token JWT
// - Protéger les routes
EOF

# ============================================
# AUTH MODULE
# ============================================

mkdir -p src/auth/dto
mkdir -p src/auth/strategies

cat > src/auth/auth.module.ts << 'EOF'
// TODO: Auth Module
// - Import JwtModule
// - Import PassportModule
// - Import UsersModule
// - Provider AuthService
// - Provider JwtStrategy
// - Export AuthService
EOF

cat > src/auth/auth.service.ts << 'EOF'
// TODO: Auth Service
// - signup(dto): créer utilisateur + générer JWT
// - signin(dto): vérifier credentials + générer JWT
// - validateUser(email, password): vérifier credentials
// - generateJwt(payload): créer token JWT
EOF

cat > src/auth/auth.controller.ts << 'EOF'
// TODO: Auth Controller
// - POST /auth/signup
// - POST /auth/signin
// - GET /auth/me (protected)
EOF

cat > src/auth/dto/signup.dto.ts << 'EOF'
// TODO: Signup DTO
// - email: string (IsEmail)
// - password: string (MinLength(8))
// - username: string (MinLength(3))
// - displayName?: string (optional)
EOF

cat > src/auth/dto/signin.dto.ts << 'EOF'
// TODO: Signin DTO
// - email: string (IsEmail)
// - password: string
EOF

cat > src/auth/strategies/jwt.strategy.ts << 'EOF'
// TODO: JWT Strategy (Passport)
// - Extraire et valider le token JWT
// - Retourner le payload (userId, email)
EOF

# ============================================
# USERS MODULE
# ============================================

mkdir -p src/users/dto
mkdir -p src/users/entities

cat > src/users/users.module.ts << 'EOF'
// TODO: Users Module
// - Import DatabaseModule
// - Provider UsersService
// - Export UsersService
EOF

cat > src/users/users.service.ts << 'EOF'
// TODO: Users Service
// - findById(id): trouver par ID
// - findByEmail(email): trouver par email
// - findByUsername(username): trouver par username
// - create(dto): créer utilisateur
// - update(id, dto): modifier utilisateur
// - remove(id): supprimer utilisateur
EOF

cat > src/users/users.controller.ts << 'EOF'
// TODO: Users Controller
// - GET /users/:id (public)
// - PUT /users/:id (protected, owner only)
// - DELETE /users/:id (protected, owner only)
EOF

cat > src/users/entities/user.entity.ts << 'EOF'
// TODO: User Entity
// - Interface User avec tous les champs
// - Correspond à la table Supabase users
EOF

cat > src/users/dto/create-user.dto.ts << 'EOF'
// TODO: Create User DTO
// - id: string
// - email: string
// - username: string
// - displayName?: string
EOF

cat > src/users/dto/update-user.dto.ts << 'EOF'
// TODO: Update User DTO (PartialType)
// - displayName?: string
// - avatarUrl?: string
// - bio?: string
EOF

# ============================================
# POSTS MODULE
# ============================================

mkdir -p src/posts/dto
mkdir -p src/posts/entities

cat > src/posts/posts.module.ts << 'EOF'
// TODO: Posts Module
// - Import DatabaseModule
// - Provider PostsService
EOF

cat > src/posts/posts.service.ts << 'EOF'
// TODO: Posts Service
// - findAll(query): liste avec pagination
// - findOne(id): trouver par ID
// - findByUser(userId): posts d'un utilisateur
// - create(userId, dto): créer post
// - update(id, dto): modifier post
// - remove(id): supprimer post
// - getFeed(userId): feed personnalisé
EOF

cat > src/posts/posts.controller.ts << 'EOF'
// TODO: Posts Controller
// - GET /posts (public, with pagination)
// - GET /posts/:id (public)
// - POST /posts (protected)
// - PUT /posts/:id (protected, owner only)
// - DELETE /posts/:id (protected, owner only)
// - GET /posts/feed (protected)
EOF

cat > src/posts/entities/post.entity.ts << 'EOF'
// TODO: Post Entity
// - Interface Post avec tous les champs
// - Correspond à la table Supabase posts
EOF

cat > src/posts/dto/create-post.dto.ts << 'EOF'
// TODO: Create Post DTO
// - caption: string (MaxLength(2200))
// - imageUrls: string[] (ArrayMinSize(1))
EOF

cat > src/posts/dto/update-post.dto.ts << 'EOF'
// TODO: Update Post DTO (PartialType)
// - caption?: string
EOF

echo ""
echo "✅ Structure NestJS générée avec succès !"
echo ""
echo "📁 Structure créée:"
echo "   backend-nestjs/"
echo "   ├── src/"
echo "   │   ├── main.ts              (Entry point)"
echo "   │   ├── app.module.ts        (Root module)"
echo "   │   ├── auth/                (Auth module)"
echo "   │   │   ├── auth.module.ts"
echo "   │   │   ├── auth.service.ts"
echo "   │   │   ├── auth.controller.ts"
echo "   │   │   ├── dto/"
echo "   │   │   │   ├── signup.dto.ts"
echo "   │   │   │   └── signin.dto.ts"
echo "   │   │   └── strategies/"
echo "   │   │       └── jwt.strategy.ts"
echo "   │   ├── users/               (Users module)"
echo "   │   │   ├── users.module.ts"
echo "   │   │   ├── users.service.ts"
echo "   │   │   ├── users.controller.ts"
echo "   │   │   ├── entities/"
echo "   │   │   │   └── user.entity.ts"
echo "   │   │   └── dto/"
echo "   │   │       ├── create-user.dto.ts"
echo "   │   │       └── update-user.dto.ts"
echo "   │   ├── posts/               (Posts module)"
echo "   │   │   ├── posts.module.ts"
echo "   │   │   ├── posts.service.ts"
echo "   │   │   ├── posts.controller.ts"
echo "   │   │   ├── entities/"
echo "   │   │   │   └── post.entity.ts"
echo "   │   │   └── dto/"
echo "   │   │       ├── create-post.dto.ts"
echo "   │   │       └── update-post.dto.ts"
echo "   │   ├── database/            (Supabase module)"
echo "   │   │   ├── database.module.ts"
echo "   │   │   └── supabase.service.ts"
echo "   │   └── common/              (Shared)"
echo "   │       ├── decorators/"
echo "   │       ├── filters/"
echo "   │       ├── interceptors/"
echo "   │       └── guards/"
echo "   ├── package.json"
echo "   ├── tsconfig.json"
echo "   ├── nest-cli.json"
echo "   ├── .env"
echo "   └── .gitignore"
echo ""
echo "📝 Prochaines étapes:"
echo "   1. cd backend-nestjs"
echo "   2. npm install"
echo "   3. Remplir .env avec credentials Supabase"
echo "   4. Implémenter les TODO dans chaque fichier"
echo "   5. npm run start:dev"
echo ""
