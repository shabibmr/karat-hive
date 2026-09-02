# apps

The two Flutter applications. Shared code lives in `../packages`, not here.

| App | Surfaces | Target |
|---|---|---|
| `kh_mobile` | Customer **or** Vendor by account role | iOS, Android |
| `kh_admin` | Platform Admin | Flutter Web |

`kh_mobile` and `kh_admin` never import each other. See `docs/Architecture-Frontend.md` §4–§5.
