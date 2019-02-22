import { Base64 } from 'js-base64'

export const base64ToState = (base64, search) => {
  // for backward compatibility
  const params = new window.URLSearchParams(search)
  const themeFromUrl = params.get('theme') || 'default'

  const str = Base64.decode(base64)
  let state
  try {
    state = JSON.parse(str)
    if (state.code === undefined) { // not valid json
      state = { code: str, mermaid: { theme: themeFromUrl } }
    }
  } catch (e) {
    state = { code: str, mermaid: { theme: themeFromUrl } }
  }
  return state
}

const defaultCode = `sequenceDiagram
    participant A as Alice
    participant B as John
    Note left of A: sequence1
    A->>B: ping
    B-->>A: pong
    opt when Z
        A->>B: hi
    end
    Note left of A: sequence2
    alt if X
        A->>B: success
    else if Y
        A->>B: fail
    end
`

export const defaultState = {
  code: defaultCode,
  mermaid: { theme: 'default' }
}
