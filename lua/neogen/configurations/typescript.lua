local function_tree = {
    {
        retrieve = "first",
        node_type = "formal_parameters",
        subtree = {
            {
                retrieve = "all",
                node_type = "required_parameter",
                subtree = {
                    { retrieve = "all", node_type = "identifier", extract = true },
                },
            },
            {
                retrieve = "all",
                node_type = "optional_parameter",
                subtree = {
                    { retrieve = "all", node_type = "identifier", extract = true },
                },
            },
        },
    },
    {
        retrieve = "first",
        node_type = "statement_block",
        subtree = {
            { retrieve = "first", node_type = "return_statement", extract = true },
        },
    },
}

return {
    parent = {
        func = { "function_declaration", "expression_statement", "variable_declaration" },
        class = { "function_declaration", "expression_statement", "variable_declaration", "class_declaration" },
        type = { "variable_declaration" },
    },

    data = {
        func = {
            ["function_declaration"] = {
                ["0"] = {

                    extract = function(node)
                        local results = {}
                        local tree = function_tree
                        local nodes = neogen.utilities.nodes:matching_nodes_from(node, tree)
                        local res = neogen.utilities.extractors:extract_from_matched(nodes)

                        results.parameters = res.identifier
                        results.return_statement = res.return_statement
                        return results
                    end,
                },
            },
            ["expression_statement|variable_declaration"] = {
                ["1"] = {
                    extract = function(node)
                        local results = {}
                        local tree = { { retrieve = "all", node_type = "function", subtree = function_tree } }
                        local nodes = neogen.utilities.nodes:matching_nodes_from(node, tree)
                        local res = neogen.utilities.extractors:extract_from_matched(nodes)

                        results.parameters = res.identifier
                        results.return_statement = res.return_statement
                        return results
                    end,
                },
            },
        },
        class = {
            ["function_declaration|class_declaration|expression_statement|variable_declaration"] = {
                ["0"] = {

                    extract = function(_)
                        local results = {}
                        results.class_tag = { "" }
                        return results
                    end,
                },
            },
        },
        type = {
            ["variable_declaration"] = {
                ["1"] = {
                    extract = function(node)
                        local res = {}
                        local tree = {
                            {
                                retrieve = "first",
                                node_type = "identifier",
                                extract = true,
                            },
                        }
                        local nodes = neogen.utilities.nodes:matching_nodes_from(node, tree)
                        local results = neogen.utilities.extractors:extract_from_matched(nodes)

                        res.type = results.identifier
                        return res
                    end,
                },
            },
        },
    },

    template = {
        annotation_convention = "jsdoc",
        use_default_comment = false,

        jsdoc = {
            { nil, "/* $1 */", { no_results = true } },
            { nil, "/**" },
            { "class_tag", " * @classdesc $1", { before_first_item = { " * ", " * @class" }, type = { "class" } } },
            { "parameters", " * @param {any} %s $1" },
            { "return_statement", " * @returns {$1|any}" },
            { "type", " * @type {$1|any}", { type = { "type" } } },
            { nil, " */" },
        },
    },
}