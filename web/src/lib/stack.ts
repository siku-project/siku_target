import axios from 'axios'
import pkg from '../../package.json'

const exact = (range: string | undefined): string => (range ?? '').replace(/^[\^~]/, '')

export interface StackEntry {
  name: string
  version: string
}

/** What the interface is built with, read from the real package versions. */
export const stack: StackEntry[] = [
  { name: 'Svelte', version: exact(pkg.devDependencies.svelte) },
  { name: 'Vite', version: exact(pkg.devDependencies.vite) },
  { name: 'Tailwind', version: exact(pkg.devDependencies.tailwindcss) },
  { name: 'shadcn-svelte', version: 'tw3' },
  { name: 'bits-ui', version: exact(pkg.dependencies['bits-ui']) },
  { name: 'Paraglide', version: exact(pkg.devDependencies['@inlang/paraglide-js']) },
  { name: 'Axios', version: axios.VERSION },
]
