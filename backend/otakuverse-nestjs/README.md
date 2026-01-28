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
