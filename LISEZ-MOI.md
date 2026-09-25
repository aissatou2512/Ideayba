# IDEAYBA en ligne — connexion par e-mail et mot de passe

Dossier : `index.html` (l'application), `config.js` (vos 2 valeurs publiques), `supabase-migration.sql` (base + stockage privé + règles de sécurité).
Tout est gratuit. Plus besoin de Google Cloud. Ne donnez jamais de mot de passe ni de clé secrète à personne.

## 1. Créer le projet Supabase
1. https://supabase.com : créez un compte, puis **New project** (région proche ; notez le mot de passe de la base pour vous).
2. **SQL Editor > New query** : collez tout `supabase-migration.sql`, puis **Run**. Si vous l'aviez déjà exécuté, vous pouvez le relancer sans risque.
3. **Table Editor** : la table `ideas` est présente (RLS activée). **Storage** : le bucket `ideayba-files` est présent et n'est pas « Public ».

## 2. Activer la connexion e-mail / mot de passe
Dans Supabase, menu **Authentication** (les intitulés peuvent varier légèrement) :
1. **Sign In / Providers > Email** : vérifiez que le fournisseur **Email** est activé (il l'est par défaut).
2. **Confirm email** (confirmation de l'adresse) :
   - **Activé (recommandé)** : après l'inscription, un e-mail contient un lien de confirmation ; l'application affiche « Vérifiez vos e-mails ».
   - **Désactivé** : la connexion est immédiate après l'inscription, sans e-mail.
3. **Longueur minimale du mot de passe** (même page) : mettez **8** (l'application exige déjà 8 caractères).
4. **URL Configuration** (après l'étape 3 ci-dessous) : **Site URL** = l'adresse de votre site ; dans **Redirect URLs**, ajoutez `https://votre-adresse.netlify.app/**`. Sans cela, les liens des e-mails (confirmation, réinitialisation) ne fonctionneront pas.
5. **Emails > Templates** (facultatif) : vous pouvez traduire les e-mails « Confirm signup » et « Reset password » en français. Ne supprimez pas le lien `{{ .ConfirmationURL }}`.
6. Limite d'envoi : le service d'e-mails gratuit de Supabase envoie très peu de messages par heure. Suffisant pour vous seule ; pour plus, configurez un SMTP dans **Project Settings > Authentication**.
7. Application personnelle : une fois votre compte créé, vous pouvez désactiver **Allow new users to sign up** pour que personne d'autre ne puisse s'inscrire (le bouton « Créer un compte » affichera « Les inscriptions sont fermées »).

## 3. Publier le site
1. https://app.netlify.com/drop : glissez ce dossier. Vous obtenez `https://….netlify.app`. Retournez à l'étape 2.4 pour y renseigner cette adresse.
2. Supabase > **Project Settings > API** : copiez **Project URL** et la clé **anon / publishable** (publique). Ouvrez `config.js` avec le Bloc-notes, remplacez les deux valeurs, enregistrez, puis glissez de nouveau le dossier sur Netlify. Ne copiez jamais la clé `service_role`.

## 4. Premier compte et reprise de vos idées
1. Ouvrez votre site > **Créer un compte** > e-mail + mot de passe (8 caractères minimum). Si la confirmation est activée, cliquez sur le lien reçu par e-mail, puis connectez-vous.
2. Ancienne version d'IDEAYBA : **Paramètres > Tout exporter (JSON)**. Nouvelle version : **Paramètres > Importer**. Attendez « Enregistré ✓ » en haut à droite avant de fermer la page.

## 5. Tests à faire chez vous
1. **Création + confirmation** : créez un compte, ouvrez le lien de l'e-mail, connectez-vous.
2. **Session** : fermez l'onglet, rouvrez le site : vous restez connectée. **Se déconnecter** (bas de la barre latérale) : retour à l'écran de connexion.
3. **Mot de passe oublié** : cliquez sur « Mot de passe oublié ? », ouvrez l'e-mail, choisissez un nouveau mot de passe, puis reconnectez-vous avec.
4. **Sauvegarde** : créez une idée, attendez « Enregistré ✓ », vérifiez la ligne dans Table Editor > `ideas`, puis ouvrez le site sur un autre appareil.
5. **Fichiers** : ajoutez une image et un fichier dans un projet, rechargez : ils réapparaissent. Storage > `ideayba-files` : ils sont dans un dossier à votre identifiant.
6. **Isolation (le plus important)** : créez un 2e compte (autre e-mail, par exemple à l'étape 2.7 avant de fermer les inscriptions) : sa liste doit être vide.
7. **Vérification des règles** (SQL Editor) :
   - `select relname, relrowsecurity from pg_class where relname = 'ideas';` doit afficher `true`.
   - `select tablename, policyname from pg_policies where tablename in ('ideas','objects');` doit lister 4 règles `ideas_*` et 4 règles `ideayba_files_*`.
8. Si « ⚠ Échec de l'enregistrement » s'affiche, vos modifications ne sont pas en ligne : cliquez dessus pour réessayer avant de fermer la page.

## 6. Installer IDEAYBA comme une application mobile (icône sur l'écran d'accueil)
De nouveaux fichiers ont été ajoutés (`manifest.webmanifest`, `sw.js`, dossier `icons/`) pour que le site puisse s'installer comme une application, sans passer par un store. Cela ne change rien à Supabase ni à vos données.

1. Ajoutez ces nouveaux fichiers à votre dépôt GitHub (mêmes commandes que la première fois, depuis le dossier ideayba-en-ligne) :
```
git add .
git commit -m "Ajout de l'installation mobile (PWA)"
git push
```
2. Vercel redéploie automatiquement en général en moins d'une minute après le push. Vérifiez sur votre tableau de bord Vercel que le déploiement est terminé.
3. Sur votre téléphone, ouvrez l'adresse Vercel de votre site (pas l'ancienne version locale) :
   - **Android (Chrome)** : un bandeau « Ajouter à l'écran d'accueil » apparaît en général tout seul après quelques secondes, ou via le menu ⋮ > « Installer l'application » / « Ajouter à l'écran d'accueil ».
   - **iPhone (Safari uniquement, pas Chrome)** : bouton Partager (le carré avec une flèche) > « Sur l'écran d'accueil ».
4. Une icône IDEAYBA (bordeaux, avec un petit accent rose) apparaît sur l'écran d'accueil. En l'ouvrant, l'application se lance en plein écran, sans barre d'adresse, comme une vraie application.
5. Ce que ça change concrètement : une icône et un lancement en plein écran. Vos données restent exactement les mêmes qu'avant (même compte, même Supabase) : ce n'est pas une deuxième application séparée.

### Limites à connaître
- Ce n'est pas un fichier .apk ou .ipa : rien à publier sur le Play Store ou l'App Store avec cette méthode. Si vous voulez ça plus tard, il faudra un outil comme Capacitor, qui reprend ce même site.
- Sur iPhone, l'icône ne s'affiche que si vous l'ajoutez depuis **Safari** (Chrome et les autres navigateurs iOS ne le proposent pas).
- Après ce déploiement, si vous rechargez l'ancienne icône déjà installée avant cette mise à jour, il se peut qu'il faille la supprimer et la réinstaller une fois pour que la nouvelle icône et le mode plein écran s'appliquent.
