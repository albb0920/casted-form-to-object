# XXX: skipIfExists will skip if inputPath points to an existing array
#      this is to allow setObjectByPath({}, ["a", "b"], []) to set a.b = []
export setObjectByPath = (store, inputPath, value, {skipIfExists} = {}) =>
  path = inputPath.slice()
  key = null

  while path.length
    key = path.shift()
    break unless key of store && typeof(store[key]) == "object"

    store = store[key]
    key = null

  while path.length
    nextKey = path.shift()

    if nextKey.match(/^\d+$/) || nextKey == ""
      store = (store[key] = [])
    else
      store = (store[key] = {})

    key = nextKey

  if key
    if typeof store != "object"
      throw "path `#{inputPath}` has bad input name, expect array or object, it's #{store}"

    store[key] = value unless skipIfExists && key of store

  else
    unless "push" of store
      throw "path `#{inputPath}` has bad input name, array, it's #{store}"

    store.push(value) unless skipIfExists

export formToObj = (form)->
  results = {}

  # FIXME: input group
  for input from form.elements
    continue unless input.name

    path = [
      input.name.match(/^[^\[]+/)[0],
      ...Array.from(input.name.matchAll(/\[(.*?)\]/g)).map((match)=> match[1])
    ]

    if input.type in ["checkbox", "radio"] && !input.checked && input.value not in ["true", "false"]
      # ensure we have an empty array if no option is selected
      setObjectByPath(results, path, [], skipIfExists: true) if path.pop() == ""
      continue

    value =
      if input.value == "true" && input.type in ["checkbox", "radio"]
        input.checked
      else if input.value == "false" && input.type == "radio" && input.checked
        false
      else if input.type == "number"
        Number(input.value)
      else
        input.value

    setObjectByPath(results, path, value)

  results
