import { RequestMethod } from '@nestjs/common';
import {
  HTTP_CODE_METADATA,
  METHOD_METADATA,
  PATH_METADATA,
  ROUTE_ARGS_METADATA,
} from '@nestjs/common/constants';
import { RouteParamtypes } from '@nestjs/common/enums/route-paramtypes.enum';
import type { ZodTypeAny } from 'zod';
import { IS_PUBLIC_KEY } from '../../src/edge/auth/public.decorator';
import { ZodValidationPipe } from '../../src/edge/validation/zod-validation.pipe';
import type { ControllerClass } from './controllers';

export type HttpMethodName = 'get' | 'post' | 'put' | 'patch' | 'delete' | 'options' | 'head';

export type DiscoveredRoute = {
  operationId: string;
  method: HttpMethodName;
  path: string;
  tag: string;
  isPublic: boolean;
  statusCode: number;
  bodySchema?: ZodTypeAny;
  querySchema?: ZodTypeAny;
  pathParams: string[];
  controllerName: string;
  handlerName: string;
};

type RouteArgsEntry = {
  index: number;
  data?: unknown;
  pipes?: unknown[];
};

const METHOD_NAMES: Record<number, HttpMethodName> = {
  [RequestMethod.GET]: 'get',
  [RequestMethod.POST]: 'post',
  [RequestMethod.PUT]: 'put',
  [RequestMethod.PATCH]: 'patch',
  [RequestMethod.DELETE]: 'delete',
  [RequestMethod.OPTIONS]: 'options',
  [RequestMethod.HEAD]: 'head',
};

function asPathSegments(value: unknown): string[] {
  if (value === undefined || value === null || value === '') return [];
  if (Array.isArray(value)) return value.flatMap((v) => asPathSegments(v));
  return String(value)
    .split('/')
    .map((s) => s.trim())
    .filter(Boolean);
}

function nestPathToOpenApi(segments: string[]): string {
  const converted = segments.map((seg) => seg.replace(/:([A-Za-z0-9_]+)/g, '{$1}'));
  return `/${converted.join('/')}`;
}

function defaultStatus(method: HttpMethodName): number {
  return method === 'post' ? 201 : 200;
}

function zodFromPipes(pipes: unknown[] | undefined): ZodTypeAny | undefined {
  if (!pipes?.length) return undefined;
  for (const pipe of pipes) {
    if (pipe instanceof ZodValidationPipe) return pipe.schema;
  }
  return undefined;
}

function discoverHandler(
  Controller: ControllerClass,
  handlerName: string,
  handler: (...args: never[]) => unknown,
): DiscoveredRoute | null {
  const methodMeta = Reflect.getMetadata(METHOD_METADATA, handler) as number | undefined;
  if (methodMeta === undefined) return null;
  const method = METHOD_NAMES[methodMeta];
  if (!method) return null;

  const controllerPath = Reflect.getMetadata(PATH_METADATA, Controller);
  const handlerPath = Reflect.getMetadata(PATH_METADATA, handler);
  const path = nestPathToOpenApi([
    ...asPathSegments(controllerPath),
    ...asPathSegments(handlerPath),
  ]);

  const httpCode = Reflect.getMetadata(HTTP_CODE_METADATA, handler) as number | undefined;
  const isPublic =
    Reflect.getMetadata(IS_PUBLIC_KEY, handler) === true ||
    Reflect.getMetadata(IS_PUBLIC_KEY, Controller) === true;

  const args =
    (Reflect.getMetadata(ROUTE_ARGS_METADATA, Controller, handlerName) as
      Record<string, RouteArgsEntry> | undefined) ?? {};

  let bodySchema: ZodTypeAny | undefined;
  let querySchema: ZodTypeAny | undefined;
  const pathParams = new Set<string>();

  for (const [key, entry] of Object.entries(args)) {
    const paramType = Number(key.split(':')[0]);
    if (paramType === RouteParamtypes.BODY) {
      bodySchema = zodFromPipes(entry.pipes) ?? bodySchema;
    } else if (paramType === RouteParamtypes.QUERY) {
      querySchema = zodFromPipes(entry.pipes) ?? querySchema;
    } else if (paramType === RouteParamtypes.PARAM) {
      if (typeof entry.data === 'string' && entry.data.length > 0) {
        pathParams.add(entry.data);
      }
    }
  }

  for (const match of path.matchAll(/\{([A-Za-z0-9_]+)\}/g)) {
    const name = match[1];
    if (name) pathParams.add(name);
  }

  const controllerName = Controller.name.replace(/Controller$/, '') || Controller.name;
  return {
    operationId: `${controllerName}_${handlerName}`,
    method,
    path,
    tag: controllerName,
    isPublic,
    statusCode: httpCode ?? defaultStatus(method),
    bodySchema,
    querySchema,
    pathParams: [...pathParams].sort(),
    controllerName,
    handlerName,
  };
}

/** Reflect Nest HTTP handlers + ZodValidationPipe schemas without booting the app. */
export function discoverRoutes(controllers: ControllerClass[]): DiscoveredRoute[] {
  const routes: DiscoveredRoute[] = [];
  for (const Controller of controllers) {
    const proto = Controller.prototype as Record<string, unknown>;
    for (const handlerName of Object.getOwnPropertyNames(proto)) {
      if (handlerName === 'constructor') continue;
      const handler = proto[handlerName];
      if (typeof handler !== 'function') continue;
      const route = discoverHandler(
        Controller,
        handlerName,
        handler as (...args: never[]) => unknown,
      );
      if (route) routes.push(route);
    }
  }
  return routes.sort((a, b) => a.path.localeCompare(b.path) || a.method.localeCompare(b.method));
}
