# Komendy
- testy: `bun test` (lub `npm run test`)
- typy/lint: `npm run typecheck`, `npm run lint`
- backend: `php artisan test`, `composer install`

# Styl kodu
- TS/ESM, brak CJS. Precyzyjne importy (destrukturyzacja).
- Małe PR-y, konwencja commitów (feat/fix/chore/docs/refactor/test).

# Workflow
- Plan → Implementacja → Weryfikacja → PR.
- TDD preferowane przy logice domenowej.
- Po większej serii zmian: uruchom typecheck i pojedyncze testy zamiast całego suite.

# Uwaga
- Używaj /clear między niezależnymi zadaniami.
- Pisz checklisty w `DOCS/TASKS.md` przy długich migracjach.
