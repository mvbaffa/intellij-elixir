// This is a generated file. Not intended for manual editing.
package org.elixir_lang.psi.impl;

import java.util.List;
import org.jetbrains.annotations.*;
import com.intellij.lang.ASTNode;
import com.intellij.psi.PsiElement;
import com.intellij.psi.PsiElementVisitor;
import com.intellij.psi.util.PsiTreeUtil;
import static org.elixir_lang.psi.ElixirTypes.*;
import org.elixir_lang.psi.*;
import com.ericsson.otp.erlang.OtpErlangObject;

public class ElixirMatchedUnqualifiedParenthesesCallImpl extends ElixirMatchedExpressionImpl implements ElixirMatchedUnqualifiedParenthesesCall {

  public ElixirMatchedUnqualifiedParenthesesCallImpl(ASTNode node) {
    super(node);
  }

  public void accept(@NotNull PsiElementVisitor visitor) {
    if (visitor instanceof ElixirVisitor) ((ElixirVisitor)visitor).visitMatchedUnqualifiedParenthesesCall(this);
    else super.accept(visitor);
  }

  @Override
  @NotNull
  public ElixirMatchedParenthesesArguments getMatchedParenthesesArguments() {
    return findNotNullChildByClass(ElixirMatchedParenthesesArguments.class);
  }

  @NotNull
  public OtpErlangObject quote() {
    return ElixirPsiImplUtil.quote(this);
  }

}
