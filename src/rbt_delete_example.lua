function Map:delete(node)
    local replace = nil;
    local parent = nil;
    if node.left~=nil and node.right~=nil then
            local x = node.right;
            while x.left~=nil do x = x.left end
            node.key=x.key;node.value=x.value;
            return self:delete(x);
    end
    if node.parent==nil then
            self.root=(node.left~=nil and {node.left} or {node.right})[1];
            replace=self.root;
            if self.root~=nil then self.root.parent=nil end;
    else
            local child = (node.left~=nil and {node.left}or{node.right})[1];
            if node.parent.left==node then node.parent.left=child;
            else node.parent.right=child end;
            if child~=nil then child.parent=node.parent end
            replace = child;
            parent = node.parent;
    end
    if node.color==BLACK then self:deleteFixUp(replace,parent) end;
    self.size = self.size-1;
end
function Map:deleteFixUp(replace,parent)
    local brother = nil;
    while replace==nil or replace.color==BLACK and replace~=self.root do
            if parent.left==replace then
                    brother=parent.right;
                    if brother.color==RED then
                            brother.color = BLACK;
                            parent.color = RED;
                            self:turn_left(parent);
                            brother=parent.right;
                    end
                    if(brother.left==nil or brother.left.color==BLACK)and(brother.right==nil or brother.right.color==BLACK)then
                            if parent.color==RED then
                                    parent.color=BLACK;
                                    brother.color=RED;
                                    break;
                            else
                                    brother.color=RED;
                                    replace=parent;
                                    parent=replace.parent;
                            end
                    else
                            if brother.left~=nil and brother.left.color==RED then
                                    brother.left.color=parent.color;
                                    parent.color=BLACK;
                                    self:turn_right(brother);
                                    self:turn_left(parent);
                            elseif brother.right~=nil and brother.right.color==RED then
                                    brother.color = parent.color;
                                    parent.color = BLACK;
                                    brother.right.color = BLACK;
                                    self:turn_left(parent);
                            end
                            break;
                    end
            else
                    brother=parent.left;
                    if brother.color==RED then
                            brother.color = BLACK;
                            parent.color = RED;
                            self:turn_right(parent);
                            brother=parent.left;
                    end
                    if(brother.left==nil or brother.left.color==BLACK)and(brother.right==nil or brother.right.color==BLACK)then
                            if parent.color==RED then
                                    parent.color=BLACK;
                                    brother.color=RED;
                                    break;
                            else
                                    brother.color=RED;
                                    replace=parent;
                                    parent=replace.parent;
                            end
                    else
                            if brother.right~=nil and brother.right.color==RED then
                                    brother.right.color=parent.color;
                                    parent.color=BLACK;
                                    self:turn_left(brother);
                                    self:turn_right(parent);
                            elseif brother.left~=nil and brother.left.color==RED then
                                    brother.color = parent.color;
                                    parent.color = BLACK;
                                    brother.left.color = BLACK;
                                    self:turn_right(parent);
                            end
                            break;
                    end
            end
    end
    if replace~=nil then replace.color=BLACK;end
end